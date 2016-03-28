class FestivalsController < ApplicationController

  autocomplete :airport, :name, :full => true, :extra_data => [:iata_code]
  
  SEARCH_RADIUS = 500

  def show
    @festival = Festival.find(params[:id])

    driving = DrivingInfoService.new(@festival)
    @price_by_car = driving.calc_driving_cost
    @time_by_car = driving.get_trip_time[0]
    @usr_location = $redis.hgetall('user')
  end

  def all
    @artists = Artist.all.order(:name)
    @genres = Genre.all.order(:name)
    @usr_location = $redis.hget('user', 'location')
  end

  # PRE-CALCULATE COORDINATES & GET AIRPORT
  def get_usr_info
    d = DistanceService.new
    d.get_usr_location(params[:usr_location])
    redirect_to root_path
  end

  # GET FESTIVAL SEARCH RESULTS
  def festival_list
    date = params[:date] == '' ? Date.today : params[:date]
    festivals = Festival.joins("INNER JOIN performances AS p ON p.festival_id = festivals.id INNER JOIN artists AS a ON p.artist_id = a.id INNER JOIN festival_genres AS fg ON fg.festival_id = festivals.id INNER JOIN genres AS g ON fg.genre_id = g.id").where('start_date >= ? AND LOWER(camping) LIKE ? AND g.name LIKE ? AND a.name LIKE ?', date, "%#{params[:camping]}%", "%#{params[:genre]}%", "%#{params[:artist]}%").distinct

    d = DistanceService.new
    origin = $redis.hgetall('user')
    @festivals = festivals.select do |f|
      dist_km = d.calc_distance(origin['lat'], origin['lng'], f)
      puts dist_km
      dist_km <= SEARCH_RADIUS
    end
    render json: @festivals
  end

  def festival_compare
    @selected_festivals = $redis.hkeys('festivals').map do |key|
      JSON.parse($redis.hget('festivals', key))
    end
  end

  # TODO: refactor
  def festival_select
    festival_json = Festival.find(params[:festivalId]).as_json
    user = $redis.hgetall('user')
    f = FestivalGridService.new
    flight = f.get_cheapest_flight(festival, user)

    festival_json['price_car'] = params[:drivingPrice]
    festival_json['time_car'] = params[:drivingTime]
    festival_json['price_flight'] = flight['PricingOptions'][0]['Price']
    festival_json['time_flight_in'] = flight[:inbound_leg]['Duration']
    festival_json['time_flight_out'] = flight[:outbound_leg]['Duration']
 
    if festival
      $redis.hset('festivals', festival.id, festival_json.to_json)
    end
    redirect_to root_path
  end
  
  def festival_unselect
    $redis.hdel('festivals', params[:festivalId])
    redirect_to root_path
  end

  def autocomplete
    input = params["query"]
    @results = Festival.autocomplete(input)

    @results = @results["airports"].to_json

    respond_to do |format|
        # format.js { render layout: false, content_type: 'text/javascript' }
        format.json { render json: @results }
    end
  end

  def flickr_images 
    festival = params[:festival].gsub(/\s\d{4}/, '')
    @festival = Festival.find_by(name: params[:festival])
  img_src = "https://api.flickr.com/services/rest/?api_key=#{ENV['FLICKR_KEY']}&method=flickr.photos.search&tags=festival&text=#{festival}&sort=relevance&per_page=10&page=1&content_type=1&format=json&nojsoncallback=1"
    response = HTTParty.get(img_src).body
    @image = JSON.parse(response)
    render json: @image
  end

  def parse_all
    render json: Festival.all, content_type: "application/json"
  end

  def search_flights
    @festival = Festival.find(params[:festival_id])

    if params[:default]
      params[:cabin_class] = "Economy"
      params[:adult] = 1
      params[:children] = 0
      params[:infants] = 0
      params[:departure_airport] = $redis.hget('user', 'departure_airport')

      d = DistanceService.new
      params[:arrival_airport] = d.get_nearest_airport(@festival.latitude, @festival.longitude, @festival.country)

    else
      params[:departure_airport] = Airport.find(params[:departure_airport_id])[:iata_code].downcase
      params[:arrival_airport] = Airport.find(params[:arrival_airport_id])[:iata_code].downcase
    end

    @valid_search = Festival.different_airport?(params[:departure_airport], params[:arrival_airport])

    @in_future = @festival.start_date > Time.now

    if @valid_search && @in_future && params[:arrival_airport]
      @first_five_results = @festival.search_flights(params)
    end
 
    @cabin_classes = [['Economy', 'Economy'], ['Premium Economy', 'PremiumEconomy'], ['Business', 'Business'], ['First Class', 'First']]
    @passenger_numbers = [['0', 0], [ '1', 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5]]
 
    respond_to do |format|
      format.js {render layout: false}
    end
  end
end
