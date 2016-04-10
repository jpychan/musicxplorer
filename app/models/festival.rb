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

  def airport(latitude, longitude)
    arrival_airport = nearest_airport(latitude, longitude)
    arrival_airport = arrival_airport["airports"][0]["code"]

    return arrival_airport
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

  def self.set_flight_search_params(params, session_id, airports)
    festival = Festival.find(params[:festival_id])
    if params[:default]
 
      params[:cabin_class] = "Economy"
      params[:adult] = 1
      params[:children] = 0
      params[:infants] = 0
      params[:departure_airport] = airports[:departure].iata_code.downcase
      params[:arrival_airport] = airports[:arrival].iata_code.downcase
      params[:outbound_date] = festival.start_date - 1
      params[:inbound_date] = festival.end_date + 1
    else
      params[:departure_airport] = airports[:departure].iata_code.downcase
      params[:arrival_airport] =  airports[:arrival].iata_code.downcase
      params[:outbound_date] = festival.start_date - 1
      params[:inbound_date] = festival.end_date + 1
    end
    return params
  end

  def save_flight_results(cheapest_result, session_id, festival_id)

    if cheapest_result

      lowest_cost = cheapest_result["PricingOptions"][0]["Price"]
      outbound_time = cheapest_result[:outbound_leg]["Duration"]
      inbound_time = cheapest_result[:inbound_leg]["Duration"]

      $redis.hmset("#{session_id}_#{festival_id}_flight", 'searched?', 'true', 'cost', lowest_cost, 'outbound_time', outbound_time, 'inbound_time', inbound_time)
    else
      $redis.hmset("#{session_id}_#{festival_id}_flight", 'searched?', 'true')
    end
  end

  def self.get_flickr_images(festival)
    url = "https://api.flickr.com/services/rest/?api_key=#{ENV['FLICKR_KEY']}&method=flickr.photos.search&tags=festival&text=#{festival}&sort=relevance&per_page=10&page=1&content_type=1&format=json&nojsoncallback=1"
    encode_url = URI.encode(url)
    img_src = URI.parse(encode_url)
    response = HTTParty.get(img_src).body
    @image = JSON.parse(response)
  end


end
  


