module Skyscanner

  include ActionView::Helpers::DateHelper

  def create_skyscanner_session(params)
    url = URI("http://partners.api.skyscanner.net/apiservices/pricing/v1.0?apiKey=#{ENV['SKYSCANNER_API']}")

    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request["accept"] = 'application/json'
    request["cache-control"] = 'no-cache'
    request.body = "country=CA&currency=CAD&locale=en-CA&adults=#{params[:adult]}&children=#{params[:children]}&infants=#{params[:infants]}&originplace=#{params[:departure_airport]}-iata&destinationplace=#{params[:arrival_airport]}-iata&outbounddate=#{params[:outbound_date]}&inbounddate=#{params[:inbound_date]}&locationschema=Iata&cabinclass=#{params[:cabin_class]}&groupPricing=true"
    puts request.body
    response = http.request(request)
    puts response

    if response.code != "201"
      session_id = nil
    else
      polling_url = response["location"]
      session_id = polling_url.split('/').last

      return session_id
    end
  end

  def get_itineraries(session_id)
    url = URI("http://partners.api.skyscanner.net/apiservices/pricing/uk2/v1.0/#{session_id}?apiKey=#{ENV['SKYSCANNER_API']}")
    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Get.new(url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request["accept"] = 'application/json'
    request["cache-control"] = 'no-cache'

    response = http.request(request)

    puts response
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
    @results = data["Itineraries"]

    if @results.length > 0

      # @results.unshift(query)
      # @results[0]["OutboundDate"] = Date.parse(@results[0]["OutboundDate"])
      # @results[0]["InboundDate"] = Date.parse(@results[0]["InboundDate"])
      
      j = 0

      while j <= @results.length - 1

        outbound_leg_id = @results[j]["OutboundLegId"]
        inbound_leg_id = @results[j]["InboundLegId"]
        agent_id = @results[j]["PricingOptions"][0]["Agents"][0]

        @results[j][:outbound_leg] = legs.select { |leg| leg["Id"] == outbound_leg_id}[0]

        if @results[j][:outbound_leg]["Duration"].class == Fixnum
          @results[j][:outbound_leg]["Duration"] = minutes_in_words(@results[j][:outbound_leg]["Duration"])
        end

        @results[j][:outbound_departure_time] = DateTime.parse(@results[j][:outbound_leg]["Departure"])
        @results[j][:outbound_departure_time] = @results[j][:outbound_departure_time].strftime('%I:%M %p')
        @results[j][:outbound_arrival_time] = DateTime.parse(@results[j][:outbound_leg]["Arrival"])
        @results[j][:outbound_arrival_time] = @results[j][:outbound_arrival_time].strftime('%I:%M %p')

        @results[j][:inbound_leg] = legs.select { |leg| leg["Id"] == inbound_leg_id}[0]


        if @results[j][:inbound_leg]["Duration"].class == Fixnum
          @results[j][:inbound_leg]["Duration"] = minutes_in_words(@results[j][:inbound_leg]["Duration"])
        end
        @results[j][:inbound_departure_time] = DateTime.parse(@results[j][:inbound_leg]["Departure"])
        @results[j][:inbound_departure_time] = @results[j][:inbound_departure_time].strftime('%I:%M %p')
        @results[j][:inbound_arrival_time] = DateTime.parse(@results[j][:inbound_leg]["Arrival"])
        @results[j][:inbound_arrival_time] = @results[j][:inbound_arrival_time].strftime('%I:%M %p')

        departure_airport_id = @results[j][:outbound_leg]["OriginStation"]
        arrival_airport_id = @results[j][:outbound_leg]["DestinationStation"]

        departure_carrier_id = @results[j][:outbound_leg]["Carriers"][0]
        arrival_carrier_id = @results[j][:inbound_leg]["Carriers"][0]

        @results[j][:departure_airport] = places.select { |place| place["Id"] == departure_airport_id }[0]
        @results[j][:arrival_airport] = places.select { |place| place["Id"] == arrival_airport_id }[0]
        @results[j][:departure_carrier] = carriers.select { |carrier| carrier["Id"] == departure_carrier_id }[0]
        @results[j][:arrival_carrier] = carriers.select { |carrier| carrier["Id"] == arrival_carrier_id }[0]
        @results[j][:agent] = agents.select { |agent| agent["Id"] == agent_id }[0]

        j += 1
      end
    end
    puts @results.length
    return @results

  end

  def minutes_in_words(minutes)
      distance_of_time_in_words(Time.at(0), Time.at(minutes * 60))
  end

end
