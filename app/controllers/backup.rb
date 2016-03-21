@outbound_date = @results["Query"]["OutboundDate"]
@inbound_date = @results["Query"]["InboundDate"]
@cabin_class = @results["Query"]["CabinClass"]


my_results = []
@first_five_results = []
(0..4).each do |i|
@first_five_results << @results["Itineraries"][i]
end

@legs = @results["Legs"] #Array of hashes

my_results[0] = {
price: @first_five_results[0]["PricingOptions"][0]["Price"],
departure_leg: @legs.select { |leg| leg["Id"] == @results["Itineraries"][0]["OutboundLegId"] },
return_leg: @legs.select { |leg| leg["Id"] == @results["Itineraries"][0]["InboundLegId"] }
}

lowest_price_result = {
outbound_leg_id: @results["Itineraries"][0]["OutboundLegId"],
inbound_leg_id: @results["Itineraries"][0]["InboundLegId"],
price: @results["Itineraries"][0]["PricingOptions"][0]["Price"],
booking_url: @results["Itineraries"][0]["PricingOptions"][0]["DeeplinkUrl"]
}

departure_leg = @legs.select { |leg| leg["Id"] == lowest_price_result[:outbound_leg_id] }
departure_leg = departure_leg[0]
departure_info = {
departure_time: departure_leg["Departure"],
arrival_time: departure_leg["Arrival"]
}
byebug

departure_info[:departing_airport_id] = departure_leg["OriginStation"]
departure_info[:departing_airport] = @results["Places"].select { |place| place["Id"] == departure_info[:departing_airport_id] }
departure_info[:departing_airport_code] = departure_info[:departing_airport][0]["Code"]
departure_info[:carrier_id] = departure_leg["Carriers"][0]
departure_info[:carrier] = @results["Carriers"].select { |carrier| carrier["Id"] == departure_info[:carrier_id] }
departure_info[:carrier_name] = departure_info[:carrier[0]["Name"]
departure_info[:arrival_airport_id] = departure_leg["DestinationStation"]
departure_info[:arrival_airport] = @results["Places"].select { |place| place["Id"] == departure_info[:departing_airport_id] }
departure_info[:arrival_airport_code] = departure_info[:arrival_airport][0]["Code"]