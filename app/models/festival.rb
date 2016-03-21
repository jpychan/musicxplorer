class Festival < ActiveRecord::Base
  has_many :festival_genres
  has_many :genres, through: :festival_genres

  validates :name, presence: true, uniqueness: true

  def search_flights(params)

    @session_id 
    @polling_url
    @data
    
    create_skyscanner_session(params)
    get_itineraries

    return @data

  end

  def create_skyscanner_session(params)
    url = URI("http://partners.api.skyscanner.net/apiservices/pricing/v1.0?apiKey=prtl6749387986743898559646983194")

    festival = Festival.find(params[:festival_id])
    outbound_date = festival.start_date - 1
    inbound_date = festival.end_date + 1

    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request["accept"] = 'application/json'
    request["cache-control"] = 'no-cache'
    # request["postman-token"] = '7e6a7b9a-78be-69ac-99ce-6ce01c5f1743'
    request.body = "country=CA&currency=CAD&locale=en-CA&adults=#{params[:adults]}&children=#{params[:children]}&infants=#{params[:infants]}&originplace=49.2827,-123.1207-latlong&destinationplace=43.7000,-79.4000-latlong&outbounddate=#{outbound_date}&inbounddate=#{inbound_date}&locationschema=LatLong&cabinclass=#{params[:cabin_class]}&groupPricing=true"
    response = http.request(request)
    @polling_url = response["location"]
    @session_id = @polling_url.split('/').last

  end


  def get_itineraries
    url = URI("http://partners.api.skyscanner.net/apiservices/pricing/uk2/v1.0/#{@session_id}?apiKey=prtl6749387986743898559646983194")
    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Get.new(url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request["accept"] = 'application/json'
    request["cache-control"] = 'no-cache'
    # request["postman-token"] = '84e760a9-cdf6-09a9-7f63-e0e0456937c7'

    response = http.request(request)
    @data = response.body
    @data = JSON.parse(@data)
    
  end
  
end