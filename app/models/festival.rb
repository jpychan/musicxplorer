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
end
  
