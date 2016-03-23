class Festival < ActiveRecord::Base

  include Skyscanner

  has_many :festival_genres
  has_many :genres, through: :festival_genres

  validates :name, presence: true, uniqueness: true

  def search_flights(params)
 
    session_id = create_skyscanner_session(params)
    data = get_itineraries(session_id)
    @results = get_first_five_results(data)

    return @results
  end

  def self.autocomplete(input)

    # url = URI("http://partners.api.skyscanner.net/apiservices/autosuggest/v1.0/CA/CAD/en-US/?query=#{input}&apiKey=prtl6749387986743898559646983194")
    # http = Net::HTTP.new(url.host, url.port)

    # request = Net::HTTP::Get.new(url)
    # request["cache-control"] = 'no-cache'
    # request["postman-token"] = 'f371f2aa-486f-979c-9b9d-9c6543ec19d1'
    # request["Accept"] = 'application/json'

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