class FestivalsController < ApplicationController
  SEARCH_RADIUS = 500
  TOO_FAR = SEARCH_RADIUS + 1   # value if ZERO_RESULTS returned in google distance matrix API
  IN_RANGE = SEARCH_RADIUS - 1

  def show

    # will take params or an obj as an arg once search form is up
    @festival = Festival.find(params[:id])
    # driving = DrivingInfoService.new(@festival)
    # @price_by_car = driving.calc_driving_cost
    # @time_by_car = driving.get_trip_time[0]

    @usr_location = $redis.hgetall('user')
    @usr_location = {
      lat: @usr_location["lat"],
      long: @usr_location["lng"]
    }

    @arrival_airport = @festival.airport(@festival.latitude, @festival.longitude)


  end

  def all
    @artists = Artist.all.order(:name)
    @genres = Genre.all.order(:name)
    @usr_location = $redis.hget('user', 'location')

    @selected_festivals = []   # temporarily here to not break the views
    #@selected_festivals = $redis.hkeys({}).map do |key|
    #  JSON.parse($redis.hget({}, key))
    #end
  end

  # PRE-CALCULATE COORDINATES FOR USER LOCATION
  def get_usr_coordinates
    d = DistanceService.new
    d.get_usr_location(params[:usr_location])
    redirect_to root_path
  end

  # GET FESTIVAL SEARCH RESULTS
  def festival_list
    festivals = Festival.joins("INNER JOIN performances AS p ON p.festival_id = festivals.id INNER JOIN artists AS a ON p.artist_id = a.id INNER JOIN festival_genres AS fg ON fg.festival_id = festivals.id INNER JOIN genres AS g ON fg.genre_id = g.id").where('start_date >= ? AND LOWER(camping) LIKE ? AND g.name LIKE ? AND a.name LIKE ?', params[:date], "%#{params[:camping]}%", "%#{params[:genre]}%", "%#{params[:artist]}%").distinct

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
  end

  def festival_select
    festival = Festival.find(params[:festivalId])
    #festival_json = festival.to_json
    
    driving = DrivingInfoService.new(festival)
    @price_by_car = driving.calc_driving_cost
    @time_by_car = driving.get_trip_time[0]
    if festival
    #  $redis.hset({}, festival.id, festival_json)
    end
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
    img_src = "https://api.flickr.com/services/rest/?api_key=#{ENV['FLICKR_KEY']}&method=flickr.photos.search&tags=festival&text=#{festival}&sort=relevance&per_page=10&content_type=1&format=json&nojsoncallback=1"
    response = HTTParty.get(img_src).body
    @image = JSON.parse(response)
    render json: @image
  end

  def parse_all
    render json: Festival.all, content_type: "application/json"
  end

 def search_flights

  @festival = Festival.find(params[:festival_id])
  user_country = $redis.hget('user', 'country')

  if params[:default]
    params[:cabin_class] = "Economy"
    params[:adult] = 1
    params[:children] = 0
    params[:infants] = 0
    params[:departure_airport] = $redis.hget('user', 'departure_airport')

  end

  d = DistanceService.new
 
  # params[:arrival_airport] = d.get_nearest_airport(@festival.latitude, @festival.longitude, @festival.country)

  @cabin_classes = [['Economy', 'Economy'], ['Premium Economy', 'PremiumEconomy'], ['Business', 'Business'], ['First Class', 'First']]
  @passenger_numbers = [['0', 0], [ '1', 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5]]

  @first_five_results = @festival.search_flights(params)

  respond_to do |format|
    format.js {render layout: false}
  end
end
  
end
