class DistanceService
  EARTH_RADIUS = 6371 # km

  def initialize(usr_location, festival)
    @usr_location = usr_location
    @festival = festival
  end
 
  def origin_point
    location = @usr_location == '' ? 'Vancouver BC' : @usr_location
    origin = GeoNamesAPI::PlaceSearch.find_by_place_name(location).geonames[0]
    {lat: origin.lat, lng: origin.lng}
  end

  def to_radians(deg)
    deg/180 * Math::PI
  end

  def calc_distance
    orig_lat = to_radians(origin_point[:lat])
    orig_lng = to_radians(origin_point[:lng])
    dest_lat = to_radians(@festival.latitude)
    dest_lng = to_radians(@festival.longitude)

    lat_diff = dest_lat - orig_lat
    lng_diff = dest_lng - orig_lng

    pt_dist = (Math.sin(lat_diff/2))**2 + Math.cos(orig_lat) * Math.cos(dest_lat) * (Math.sin(lng_diff/2))**2
    central_angle = 2 * Math.atan2(Math.sqrt(pt_dist), Math.sqrt(1-pt_dist))
    EARTH_RADIUS * central_angle
  end
end
