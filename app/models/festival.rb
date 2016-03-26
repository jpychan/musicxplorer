class Festival < ActiveRecord::Base

  include Skyscanner

  has_many :performances, dependent: :destroy
  has_many :artists, through: :performances
  has_many :festival_genres, dependent: :destroy
  has_many :genres, through: :festival_genres

  validates :name, presence: true

  def search_flights(params)
 
    session_id = create_skyscanner_session(params)
    data = get_itineraries(session_id)
    @results = get_first_five_results(data)

    return @results
  end

  def airport(latitude, longitude)
    arrival_airport = nearest_airport(latitude, longitude)
    arrival_airport = arrival_airport["airports"][0]["code"]

    return arrival_airport
  end

  def self.autocomplete(input)

    #Autocomplete Search
    url = URI("https://airport.api.aero/airport/match/#{input}?user_key=#{ENV['AIRPORT_API_USERKEY']}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["dataType"] = "application/json"
    request["cache-control"] = 'no-cache'
    response = http.request(request)
    response = response.body
    response = JSON.parse(response[/{.+}/])

    return response

  end
end
  
