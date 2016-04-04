class Festival < ActiveRecord::Base
  include Skyscanner

  has_many :performances, dependent: :destroy
  has_many :artists, through: :performances
  has_many :festival_genres, dependent: :destroy
  has_many :genres, through: :festival_genres

  validates :name, presence: true

  def search_flights(params)
    Rails.cache.fetch("flights/#{params["festival_id"]}/#{params["departure_airport"]}/#{params["arrival_airport"]}", expires_in: 30.minutes) do
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
end
  
