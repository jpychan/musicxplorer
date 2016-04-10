class Festival < ActiveRecord::Base
  include Skyscanner

  SEARCH_RADIUS = 500

  has_many :performances, dependent: :destroy
  has_many :artists, through: :performances
  has_many :festival_genres, dependent: :destroy
  has_many :genres, through: :festival_genres

  validates :name, presence: true

  def search_flights(params)
    key = "flights/#{params["festival_id"]}/#{params["departure_airport"]}/#{params["arrival_airport"]}"
    Rails.cache.fetch(key, expires_in: 30.minutes) do
      session_id = create_skyscanner_session(params)
      if session_id
        data = get_itineraries(session_id)
        @results = get_first_five_results(data)
      else
        @results = []
      end
    end
  end

  def self.different_airport?(departure, arrival)
    departure != arrival
  end

  def self.upcoming
    Rails.cache.fetch("upcoming_festivals", expires_in: 1.hours) do
      Festival.includes(:genres).where('start_date > ?', Date.today).order(:start_date).limit(20)
    end
  end

  def self.search(params, date, sessionId)
    @festivals = self.joins("INNER JOIN performances AS p ON p.festival_id = festivals.id INNER JOIN artists AS a ON p.artist_id = a.id INNER JOIN festival_genres AS fg ON fg.festival_id = festivals.id INNER JOIN genres AS g ON fg.genre_id = g.id").where('start_date >= ? AND LOWER(camping) LIKE ? AND g.name LIKE ? AND a.name LIKE ?', date, "%#{params[:camping]}%", "%#{params[:genre]}%", "%#{params[:artist]}%").distinct

    d = DistanceService.new
    origin = $redis.hgetall(sessionId)
    @festivals = @festivals.select do |f|
      dist_km = d.calc_distance(origin['lat'], origin['lng'], f)
      puts dist_km
      dist_km <= SEARCH_RADIUS 
    end
  end

  def self.set_background(num_of_festivals)

    img_array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]

    @img_classes = []

    num_of_festivals.times do
      i = rand(img_array.length)
      @img_classes << img_array[i]
    end

    @img_classes

  end

  def validate_bus_search(festival, usr_location)

    depart_from = { city: usr_location["city"], state: usr_location["state"]}
    return_from = { city: festival.city, state: festival.state }

    if festival.country != "CA" && festival.country != "US"
      return "Sorry, bus schedules are currently only available for Canada and US"
    elsif depart_from == return_from
      return "Festival is located in your home city. You're already there!"
    elsif Date.today > festival.end_date
      return "Festival has already ended."
    elsif Date.today >= festival.start_date
      return "Festival already in progress."
    else
      return nil
    end
  end

  def validate_flight_search(festival, usr_location, session_id)

    departure_airport = $redis.hget(session_id, 'departure_airport_iata')
    arrival_airport = DistanceService.new.get_nearest_airport(festival.latitude, festival.longitude, festival.country).iata_code.downcase
    
    if departure_airport == arrival_airport
      return "Festival is located in your home city. Try the driving directions!"
    elsif Date.today > festival.end_date
      return "Festival has already ended."
    elsif Date.today >= festival.start_date
      return "Festival already in progress."
    else
      return nil
    end
  end

  def save_bus_data(greyhound_data, festival_id, session_id)
    if greyhound_data.is_a? Hash

      greyhound_data[:depart].each do |key, schedule|
        @lowest_cost = []
        @lowest_cost << schedule[:cost].to_f
        @lowest_cost = @lowest_cost.min
    end

      bus_time = greyhound_data[:depart][0][:travel_time]

      redis_key = "#{session_id}_#{festival_id}_bus"

      $redis.hmset("#{redis_key}", 'searched?', 'true', 'cost', @lowest_cost, 'time', bus_time)
     else
      $redis.hmset("#{redis_key}", 'searched?', 'true')
    end
    $redis.expire("#{redis_key}", 1800)
  end


  def self.get_flickr_images(festival)
    url = "https://api.flickr.com/services/rest/?api_key=#{ENV['FLICKR_KEY']}&method=flickr.photos.search&tags=festival&text=#{festival}&sort=relevance&per_page=10&page=1&content_type=1&format=json&nojsoncallback=1"
    encode_url = URI.encode(url)
    img_src = URI.parse(encode_url)
    response = HTTParty.get(img_src).body
    @image = JSON.parse(response)
  end

  def get_festival_travel_data(session_id, festival, user_location, params)
    festival_json = festival.as_json

    @fg = FestivalGridService.new

    bus = $redis.hgetall("#{session_id}_#{festival.id}_bus")
    # byebug
    if bus['searched?'] == 'true'
      festival_json['price_bus'] = bus["cost"]
      festival_json['time_bus'] = bus["time"]
    else
      bus = @fg.get_first_bus(festival, session_id)
      if bus && bus.is_a?(Hash)
        festival_json['price_bus'] = bus[:cost]
        festival_json['time_bus'] = bus[:travel_time]
      end
    end

    flight = $redis.hgetall("#{session_id}_#{festival.id}_flight")
    
    if flight['searched?'] == 'true'
      festival_json['price_flight'] = flight['cost']
      festival_json['time_flight_in'] = flight['outbound_time']
      festival_json['time_flight_out'] = flight['inbound_time']
    else
      result = @fg.get_cheapest_flight(festival, user_location)
      if result
        festival_json['price_flight'] = flight['PricingOptions'][0]['Price']
        festival_json['time_flight_in'] = flight[:inbound_leg]['Duration']
        festival_json['time_flight_out'] = flight[:outbound_leg]['Duration']
      end
    end
    festival_json['price_car'] = params["drivingPrice"]
    festival_json['time_car'] = params["drivingTime"]
    festival_json
  end


end
  


