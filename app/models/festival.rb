class Festival < ActiveRecord::Base
  has_many :festival_genres
  has_many :genres, through: :festival_genres

  validates :name, presence: true, uniqueness: true

  def search_flights(params)
   
    session_id = create_skyscanner_session(params)
    data = get_itineraries(session_id)
    @results = get_first_five_results(data)

    return @results
  end

  def nearest_airport(lat, long)
    lat = lat.to_s
    long = long.to_s

    # LONG AND LAT
    url = URI("https://airport.api.aero/airport/nearest/#{lat}/#{long}?user_key=0d77ca209a119446e1b385afb6dac816")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["cache-control"] = 'no-cache'

    response = http.request(request)
    response = response.body
    response = JSON.parse(response[/{.+}/])
  end

  def self.autocomplete(input)

    # url = URI("http://partners.api.skyscanner.net/apiservices/autosuggest/v1.0/CA/CAD/en-US/?query=#{input}&apiKey=prtl6749387986743898559646983194")
    # http = Net::HTTP.new(url.host, url.port)

    # request = Net::HTTP::Get.new(url)
    # request["cache-control"] = 'no-cache'
    # request["postman-token"] = 'f371f2aa-486f-979c-9b9d-9c6543ec19d1'
    # request["Accept"] = 'application/json'

    #Autocomplete Search
    url = URI("https://airport.api.aero/airport/match/#{input}?user_key=0d77ca209a119446e1b385afb6dac816")

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

  def create_skyscanner_session(params)
    url = URI("http://partners.api.skyscanner.net/apiservices/pricing/v1.0?apiKey=prtl6749387986743898559646983194")

    festival = Festival.find(params[:festival_id])
    outbound_date = festival.start_date - 1
    inbound_date = festival.end_date + 1
    arrival_airport = nearest_airport(festival.latitude, festival.longitude)
    arrival_airport = arrival_airport["airports"][0]["code"].downcase
    departure_airport = params[:departure_airport].downcase

    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request["accept"] = 'application/json'
    request["cache-control"] = 'no-cache'
    request.body = "country=CA&currency=CAD&locale=en-CA&adults=#{params[:adults]}&children=#{params[:children]}&infants=#{params[:infants]}&originplace=#{departure_airport}-iata&destinationplace=#{arrival_airport}-iata&outbounddate=#{outbound_date}&inbounddate=#{inbound_date}&locationschema=Iata&cabinclass=#{params[:cabin_class]}&groupPricing=true"
    response = http.request(request)
    polling_url = response["location"]
    session_id = polling_url.split('/').last

    return session_id
  end


  def get_itineraries(session_id)
    url = URI("http://partners.api.skyscanner.net/apiservices/pricing/uk2/v1.0/#{session_id}?apiKey=prtl6749387986743898559646983194")
    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Get.new(url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request["accept"] = 'application/json'
    request["cache-control"] = 'no-cache'

    response = http.request(request)
    response = response.body
    response = JSON.parse(response)
    return response    
  end

  def get_first_five_results(data)

    legs = data["Legs"]
    places = data["Places"]
    query = data["Query"]
    carriers = data["Carriers"]
    agents = data["Agents"]
    @first_five_results = JsonPath.on(data, '$..Itineraries[:4]')

    j = 0

    while j <= @first_five_results.length - 1
      outbound_leg_id = @first_five_results[j]["OutboundLegId"]
      inbound_leg_id = @first_five_results[j]["InboundLegId"]
      agent_id = @first_five_results[j]["PricingOptions"][0]["Agents"][0]

      @first_five_results[j][:outbound_leg] = legs.select { |leg| leg["Id"] == outbound_leg_id}[0]

      @first_five_results[j][:inbound_leg] = legs.select { |leg| leg["Id"] == inbound_leg_id}[0]

      departure_airport_id = @first_five_results[j][:outbound_leg]["OriginStation"]
      arrival_airport_id = @first_five_results[j][:outbound_leg]["DestinationStation"]

      departure_carrier_id = @first_five_results[j][:outbound_leg]["Carriers"][0]
      arrival_carrier_id = @first_five_results[j][:inbound_leg]["Carriers"][0]

      @first_five_results[j][:departure_airport] = places.select { |place| place["Id"] == departure_airport_id }[0]
      @first_five_results[j][:arrival_airport] = places.select { |place| place["Id"] == arrival_airport_id }[0]
      @first_five_results[j][:departure_carrier] = carriers.select { |carrier| carrier["Id"] == departure_carrier_id }[0]
      @first_five_results[j][:agent] = agents.select { |agent| agent["Id"] == agent_id }[0]

      j += 1
    end

      return @first_five_results
  end
  

end