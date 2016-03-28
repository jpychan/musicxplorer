class DistanceService
  EARTH_RADIUS = 6371 # km

  def initialize
  end

  def get_usr_location(usr_location)
    location = usr_location == '' ? 'Vancouver BC' : usr_location
    if $redis.hget('user', 'location') == location
      $redis.hgetall('user')
    else
      origin_point(location)
    end
  end
   
  def origin_point(location)
    origin = GeoNamesAPI::PlaceSearch.find_by_place_name(location).geonames[0]
    $redis.hmset('user', 'location', location, 'lat', origin.lat, 'lng', origin.lng)
  end

  def to_radians(deg)
    deg.to_f/180 * Math::PI
  end

  def calc_distance(origin, festival)
    orig_lat = to_radians(origin['lat'])
    orig_lng = to_radians(origin['lng'])
    dest_lat = to_radians(festival.latitude)
    dest_lng = to_radians(festival.longitude)

    lat_diff = dest_lat - orig_lat
    lng_diff = dest_lng - orig_lng

    pt_dist = (Math.sin(lat_diff/2))**2 + Math.cos(orig_lat) * Math.cos(dest_lat) * (Math.sin(lng_diff/2))**2
    central_angle = 2 * Math.atan2(Math.sqrt(pt_dist), Math.sqrt(1-pt_dist))
    EARTH_RADIUS * central_angle
  end
end
