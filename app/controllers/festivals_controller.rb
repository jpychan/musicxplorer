class FestivalsController < ApplicationController
  autocomplete :airport, :name, :full => true, :extra_data => [:id, :iata_code]
  SEARCH_RADIUS = 500

  before_action :set_search_and_user_location, only: [:show, :all, :festival_subscriptions]
  before_action :load_favourite_festivals, only: [:show, :all, :festival_subscriptions]

  def all
    @genres = Genre.all.order(:name)
    @festivals = Festival.upcoming
    @img_classes = Festival.set_background(@festivals.length)
  end

  def show
    @festival = Festival.find(params[:id])
    @inNA = bus_available(@usr_location["country"])

    if @inNA
      @busLink = "/search_greyhound?default=true&festival_id=#{@festival.id}"
    else
      @busLink = "#"
    end

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
    date = params[:date] == '' ? Date.today : params[:date]
    @festivals = Festival.search(params, date, session.id)

    @img_classes = Festival.set_background(@festivals.length)

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
    # festival_json = festival.as_json
    @usr_location = $redis.hgetall(session.id)

    festival_json = festival.get_festival_travel_data(session.id, festival, @usr_location, params)

    # bus = $redis.hget("#{session.id}_#{festival.id}_bus", 'searched?')

    # if bus == 'true'
    #   festival_json['price_bus'] = bus["cost"]
    #   festival_json['time_bus'] = bus["time"]
    # else
    #   bus = fg.get_first_bus(festival, session.id)
    #   if bus && bus.is_a?(Hash)
    #     festival_json['price_bus'] = bus[:cost]
    #     festival_json['time_bus'] = bus[:travel_time]
    #   end
    # end

    # flight = $redis.hgetall("#{session.id}_#{festival.id}_flight", 'searched?')
    
    # if flight == 'true'
    #   festival_json['price_flight'] = flight['cost']
    #   festival_json['time_flight_in'] = flight['outbound_time']
    #   festival_json['time_flight_out'] = flight['inbound_time']
    # else
    #   result = fg.get_cheapest_flight(festival, @usr_location)
    #   if result
    #     festival_json['price_flight'] = flight['PricingOptions'][0]['Price']
    #     festival_json['time_flight_in'] = flight[:inbound_leg]['Duration']
    #     festival_json['time_flight_out'] = flight[:outbound_leg]['Duration']
    #   end
    # end

    # festival_json['price_car'] = params["drivingPrice"]
    # festival_json['time_car'] = params["drivingTime"]

    if festival
      $redis.hmset("#{session.id}_saved", festival.id, festival_json.to_json)
    end

    head :created
  end
  
  def festival_unselect
    $redis.hdel("#{session.id}_saved", params[:festivalId])
    head :ok
  end

  # def autocomplete
  #   input = params["query"]
  #   @results = Festival.autocomplete(input)
  #   @results = @results["airports"].to_json

  #   respond_to do |format|
  #     format.json { render json: @results }
  #   end
  # end

  def flickr_images 

    festival = params[:festival].gsub(/\s\d{4}/, '')

    @image = Festival.get_flickr_images(festival)

    render json: @image
  end

  def parse_all
    render json: Festival.all, content_type: "application/json"
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

    @festival.save_flight_results(@results[0], session.id, @festival.id)

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
    @depart_from = { city: @usr_location["city"], state: @usr_location["state"]}
    @return_date = (@festival.end_date + 1).strftime
    @return_from = { city: @festival.city, state: @festival.state }
    trip_type = "Round Trip"
    browser = "phantomjs"
    if @festival.country != "CA" && @festival.country != "US"
      @greyhound_data = "Sorry, bus schedules are currently only available for Canada and US"
    elsif @depart_from == @return_from
      @greyhound_data = "Festival is located in your home city. You're already there!"
    elsif Date.today > @festival.end_date
      @greyhound_data = "Festival has already ended."
    elsif Date.today >= @festival.start_date
      @greyhound_data = "Festival already in progress."
    else
      ghound = GreyhoundScraper.new(@depart_date, @depart_from, @return_date, @return_from, trip_type, browser)
      @greyhound_data = ghound.run

      # testing - test data
      # @greyhound_data = "some error"
      # @greyhound_data = {:depart=>{0=>{:cost=>"79.00", :start_time=>"12:15AM", :end_time=>"07:40AM", :travel_time=>"7h 25m"}, 1=>{:cost=>"79.00", :start_time=>"06:30AM", :end_time=>"12:15PM", :travel_time=>"5h 45m"}, 2=>{:cost=>"88.00", :start_time=>"12:30PM", :end_time=>"05:30PM", :travel_time=>"5h 00m"}, 3=>{:cost=>"81.00", :start_time=>"02:30PM", :end_time=>"07:30PM", :travel_time=>"5h 00m"}, 4=>{:cost=>"81.00", :start_time=>"06:00PM", :end_time=>"11:45PM", :travel_time=>"5h 45m"}}, :return=>{0=>{:cost=>"", :start_time=>"08:00AM", :end_time=>"01:20PM", :travel_time=>"5h 20m"}, 1=>{:cost=>"", :start_time=>"09:15AM", :end_time=>"04:40PM", :travel_time=>"7h 25m"}, 2=>{:cost=>"", :start_time=>"12:01PM", :end_time=>"05:00PM", :travel_time=>"4h 59m"}, 3=>{:cost=>"", :start_time=>"03:30PM", :end_time=>"09:30PM", :travel_time=>"6h 00m"}, 4=>{:cost=>"", :start_time=>"11:15PM", :end_time=>"05:05AM", :travel_time=>"5h 50m"}}}
    end


    @festival.save_bus_data(@greyhound_data, @festival.id, session.id)

    # byebug
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  protected 
    def set_search_and_user_location
      @artists = Artist.all.order(:name)
      @genres = Genre.all.order(:name)

      @usr_location = $redis.hgetall(session.id)
      # byebug
      # else
        # usr_ip = request.remote_ip
        # url = "http://ip-api.com/json/#{usr_ip}"
        # http = Net::HTTP.new(url.host, url.port)
        # request = Net::HTTP::Post.new(url)
        # response = http.request(request)
        # puts response

      @usr_location_city = "#{@usr_location["city"]}, #{@usr_location["state"]}" || 'Vancouver, BC'

      @usr_location_coord = {
      lat: @usr_location["lat"],
      long: @usr_location["lng"]
    }
    end

    def load_favourite_festivals
      fg = FestivalGridService.new
      @selected_festivals = fg.get_saved_festivals(session.id)
    end

    def bus_available(country)
      if country == 'CA' || country == 'US'
        true
      else
        false
      end
    end
end
