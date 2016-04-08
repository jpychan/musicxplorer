class DistanceService
  EARTH_RADIUS = 6371 # km

  def initialize
  end

  def set_usr_location(usr_location, session_id)
    # byebug
    departure_airport = get_nearest_airport(usr_location[:lat], usr_location[:lng], usr_location[:country])
    departure_airport_id = departure_airport.id
    departure_airport_iata = departure_airport.iata_code.downcase
    user_location = $redis.hmset(session_id, 'lat', usr_location[:lat], 'lng', usr_location[:lng], 'city', usr_location[:city], 'state', usr_location[:state], 'country', usr_location[:country], 'departure_airport_id', departure_airport_id, 'departure_airport_iata', departure_airport_iata)

  end

  def to_radians(deg)    deg.to_f/180.0 * Math::PI
  end

  def calc_distance(o_lat, o_long, destination)
    orig_lat = to_radians(o_lat)
    orig_lng = to_radians(o_long)
    dest_lat = to_radians(destination.latitude)
    dest_lng = to_radians(destination.longitude)

    lat_diff = dest_lat - orig_lat
    lng_diff = dest_lng - orig_lng

    pt_dist = (Math.sin(lat_diff/2))**2 + Math.cos(orig_lat) * Math.cos(dest_lat) * (Math.sin(lng_diff/2))**2
    central_angle = 2 * Math.atan2(Math.sqrt(pt_dist), Math.sqrt(1-pt_dist))
    EARTH_RADIUS * central_angle
  end

  def get_nearest_airport(latitude, longitude, country)
    airport_list = Airport.where("country = ?", country)

    @airport_distances = airport_list.map do |f|
      calc_distance(latitude, longitude, f)
    end

    departure_airport_index = @airport_distances.index(@airport_distances.min)
    nearest_airport = airport_list[departure_airport_index]
  end
end
