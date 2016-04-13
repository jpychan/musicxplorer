class FestivalsController < ApplicationController
  autocomplete :airport, :name, :full => true
  autocomplete :festival, :name, :full => true
  SEARCH_RADIUS = 500

  before_action :set_search_and_user_location, only: [:show, :festival_subscriptions]
  before_action :load_favourite_festivals, only: [:show, :all, :festival_subscriptions]

  def all

    set_search_and_user_location

    @genres = Genre.all.order(:name)
    @festivals = Festival.upcoming
    @img_classes = Festival.set_background(@festivals.length)
  end

  def show
    @festival = Festival.find(params[:id])

    @bus_error = @festival.validate_bus_search(@festival, @usr_location)
    @flight_error = @festival.validate_flight_search(@festival, @usr_location, session.id)

    @festival_saved = $redis.hget("#{session.id}_saved", "#{@festival.id}")

    driving = DrivingInfoService.new(@festival, session.id)
    @price_by_car = driving.calc_driving_cost
    @time_by_car = driving.get_trip_time[0]
  end

  # PRE-CALCULATE COORDINATES FOR LOCATION
  def set_usr_info
    d = DistanceService.new
    d.set_usr_location(params[:usr_location], session.id)
    head :ok
  end

  # GET FESTIVAL SEARCH RESULTS
  def festival_list
    @festivals = []

    if params[:festival_name] == ''
      params[:festival_id] = ''
    end

    if params[:festival_id].length > 0
      id = params[:festival_id].to_i
      @festivals << Festival.find(id)
    else
      date = params[:date] == '' ? Date.today : params[:date]

      @festivals = Festival.search(params, date, session.id)
    end

    @img_classes = Festival.set_background(@festivals.length)

    @festivals_hash = []

    @festivals.each do |festival|
      hash = {
        id: festival.id,
        name: festival.name,
        date: festival.date,
        city: festival.city,
        state: festival.state, 
        lat: festival.latitude, 
        lng: festival.longitude 
      }

      @festivals_hash << hash
    end

    gon.festivals = @festivals_hash
    
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  # AUTO REFRESH
  def festival_subscriptions
    render json: @selected_festivals
  end

  # TODO: refactor!
  def festival_select
  # byebug
    festival = Festival.find(params[:festivalId].to_i)
    @usr_location = $redis.hgetall(session.id)

    festival_json = festival.get_festival_travel_data(session.id, festival, @usr_location, params)

    if festival
      $redis.hmset("#{session.id}_saved", festival.id, festival_json.to_json)
    end

    head :created
  end
  
  def festival_unselect
    $redis.hdel("#{session.id}_saved", params[:festivalId])
    head :ok
  end

  def flickr_images 

    festival = params[:festival].gsub(/\s\d{4}/, '')

    @image = Festival.get_flickr_images(festival)

    render json: @image
  end

  def search_flights
    # byebug
    @festival = Festival.find(params[:festival_id])
    @search_params = params
    @airports = Airport.set_airports(params, session.id, @festival)
    @search_params = @festival.set_flight_search_params(@search_params, session.id, @airports)

    if flight_exists?(@festival)
      @results = @festival.search_flights(params)
    end

    @results = Kaminari.paginate_array(@results).page(params[:page]).per(10)

    @festival.save_flight_results(@results[0], session.id, @festival.id, @airports)

    @cabin_classes = [['Economy', 'Economy'], ['Premium Economy', 'PremiumEconomy'], ['Business', 'Business'], ['First Class', 'First']]
    @passenger_numbers = [['0', 0], [ '1', 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5]]

    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def search_greyhound

    @festival = Festival.find(params[:festival_id])
    @usr_location = $redis.hgetall(session.id)
    @depart_date = (@festival.start_date - 1).strftime

    if @usr_location["state"] == "BC"
      @depart_from = { city: "Vancouver", state: "BC" }
    else
      @depart_from = { city: @usr_location["city"], state: @usr_location["state"]}
    end

    @return_date = (@festival.end_date + 1).strftime
    @return_from = { city: @festival.city, state: @festival.state }
    trip_type = "Round Trip"
    browser = "phantomjs"
  
    key = "bus/#{@festival.id}/#{@depart_from}"
    ghound = GreyhoundScraper.new(@depart_date, @depart_from, @return_date, @return_from, trip_type, browser)
    @greyhound_data = ghound.run

      # testing - test data
      # @greyhound_data = "some error"
      # @greyhound_data = {:depart=>{0=>{:cost=>"79.00", :start_time=>"12:15AM", :end_time=>"07:40AM", :travel_time=>"7h 25m"}}, :return=>{0=>{:cost=>"", :start_time=>"08:00AM", :end_time=>"01:20PM", :travel_time=>"5h 20m"}}}

    @festival.save_bus_data(@greyhound_data, @festival.id, session.id)


    # byebug
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  protected 
    def set_search_and_user_location
      @genres = Genre.all.order(:name)
      @all_festivals = Festival.all.order(:name)

      @usr_location = $redis.hgetall(session.id)

      if @usr_location == {}
        # usr_ip = '207.81.151.23'
        usr_ip = request.remote_ip
        url = URI("http://ip-api.com/json/#{usr_ip}")
        http = Net::HTTP.new(url.host, url.port)
        request = Net::HTTP::Post.new(url)
        response = http.request(request)
        response = JSON.parse(response.body)
        status = response["status"]
        puts response

        if status == "fail"

          @usr_location = $redis.hmset(session.id, 'lat', '49.246292', 'lng', '-123.116226', 'city', 'Vancouver', 'state', 'BC', 'country', 'CA', 'departure_airport_id', '7', 'departure_airport_iata', 'yvr')

        else
          departure_airport = DistanceService.new.get_nearest_airport(response["lat"], response["lon"], response["countryCode"])
          departure_airport_id = departure_airport.id
          departure_airport_iata = departure_airport.iata_code.downcase

          @usr_location = $redis.hmset(session.id, 'lat', response["lat"], 'lng', response["lon"], 'city', response["city"], 'state', response["region"], 'country', response["countryCode"], 'departure_airport_id', departure_airport_id, 'departure_airport_iata', departure_airport_iata)
        end

        @usr_location_city = "#{response["city"]}, #{response["region"]}"

        @usr_location_coord = {
        lat: response["lat"],
        long: response["lon"]
        }

      else
        @usr_location_city = "#{@usr_location["city"]}, #{@usr_location["state"]}"

        @usr_location_coord = {
        lat: @usr_location["lat"],
        long: @usr_location["lng"]
        }
      end
    end

    def load_favourite_festivals
      fg = FestivalGridService.new
      @selected_festivals = fg.get_saved_festivals(session.id)
    end

end
