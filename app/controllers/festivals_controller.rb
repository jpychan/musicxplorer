class FestivalsController < ApplicationController

  respond_to :html, :js, :json

  before_filter :set_form

  def show
    @festival = Festival.find(params[:id])
    render :show
  end

  def search_flights

    # @first_five_results = []
    # @first_five_results[0] = 
    # {
    #   departure: "YVR",
    #   arrival: "YYJ"
    # }
    # @first_five_results[1] = 
    # {
    #   departure: "YYJ",
    #   arrival: "YVR"
    # }

    @festival = Festival.find(params[:festival_id])
    @results = @festival.search_flights(params)
       
    # legs = JsonPath.on(@results, '$.Legs').flatten
    # places = JsonPath.on(@results, '$.Places').flatten
    # query = JsonPath.on(@results, '$.Query')
    # carriers = JsonPath.on(@results, '$.Carriers')[0]
    # agents = JsonPath.on(@aresults, '$.Agents')[0]

    legs = @results["Legs"]
    places = @results["Places"]
    query = @results["Query"]
    carriers = @results["Carriers"]
    agents = @results["Agents"]

    @first_five_results = JsonPath.on(@results, '$..Itineraries[:4]')

    for i in 0..4
      outbound_leg_id = @first_five_results[i]["OutboundLegId"]
      inbound_leg_id = @first_five_results[i]["InboundLegId"]
      agent_id = @first_five_results[i]["PricingOptions"][0]["Agents"][0]

      @first_five_results[i][:outbound_leg] = legs.select { |leg| leg["Id"] == outbound_leg_id}[0]

      @first_five_results[i][:inbound_leg] = legs.select { |leg| leg["Id"] == inbound_leg_id}[0]

      departure_airport_id = @first_five_results[i][:outbound_leg]["OriginStation"]
      arrival_airport_id = @first_five_results[i][:outbound_leg]["DestinationStation"]

      departure_carrier_id = @first_five_results[i][:outbound_leg]["Carriers"][0]
      arrival_carrier_id = @first_five_results[i][:inbound_leg]["Carriers"][0]

      @first_five_results[i][:departure_airport] = places.select { |place| place["Id"] == departure_airport_id }[0]
      @first_five_results[i][:arrival_airport] = places.select { |place| place["Id"] == arrival_airport_id }[0]
      @first_five_results[i][:departure_carrier] = carriers.select { |carrier| carrier["Id"] == departure_carrier_id }[0]
      @first_five_results[i][:agent] = agents.select { |agent| agent["Id"] == agent_id }[0]

    end

    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def all
    render :all
  end

  def set_form
    @cabin_classes = [['Economy', 'Economy'], ['Premium Economy', 'PremiumEconomy'], ['Business', 'Business'], ['First Class', 'First']]
    @passenger_numbers = [['0', 0], [ '1', 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5]]
  end

end
