class FestivalGridService
  include Skyscanner

  def initialize
  end

  def get_cheapest_flight(festival, user)
    flight_params = {
      departure_airport: user['airport'] || 'yvr',
      festival_id: festival.id,
      cabin_class: 'Economy',
      adults: 1,
      children: 0,
      infants: 0
      }
     festival.search_flights(flight_params)[0]
  end
end
