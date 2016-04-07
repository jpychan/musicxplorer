class DistanceService
  EARTH_RADIUS = 6371 # km

  def initialize
  end

  def get_usr_location(usr_location, sessionId)
    location = usr_location == '' ? 'Vancouver, BC' : usr_location
    if $redis.hget(sessionId, 'location') == location
      $redis.hgetall(sessionId)
    else
      origin_point(location, sessionId)
    end
  end
   
  def origin_point(location, sessionId)
    origin = GeoNamesAPI::PlaceSearch.find_by_place_name(location).geonames[0]
    departure_airport = get_nearest_airport(origin.lat, origin.lng, origin.country_code)
    user_location = $redis.hmset(sessionId, 'location', location, 'lat', origin.lat, 'lng', origin.lng, 'country', origin.country_code, 'departure_airport', departure_airport)
    return user_location
  end

  def to_radians(deg)
    deg.to_f/180.0 * Math::PI
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
    nearest_airport = airport_list[departure_airport_index][:iata_code].downcase
  end
end
