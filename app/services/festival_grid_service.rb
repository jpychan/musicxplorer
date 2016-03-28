class FestivalGridService
  include Skyscanner

  def initialize
  end

  def get_cheapest_flight(festival, user)
    d = DistanceService.new
    flight_params = {
      departure_airport: user['airport'] || 'yvr',
      arrival_airport: d.get_nearest_airport(festival.latitude, festival.longitude, festival.country),
      festival_id: festival.id,
      cabin_class: 'Economy',
      adults: 1,
      children: 0,
      infants: 0
      }
     festival.search_flights(flight_params)[0]
  end
end
