class Airport < ActiveRecord::Base

  def self.set_airports(params, session_id, festival)
    airports = {}
   if params[:default]
      airports[:departure] = Airport.find($redis.hget(session_id, 'departure_airport_id'))
      airports[:arrival] = DistanceService.new.get_nearest_airport(festival.latitude, festival.longitude, festival.country)
    else
      airports[:departure] = Airport.find(params[:departure_airport_id])
      airports[:arrival] = Airport.find(params[:arrival_airport_id])
    end

    airports
  end

end
