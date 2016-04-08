class FestivalGridService
  include Skyscanner

  def initialize
  end

  def get_saved_festivals(session_id)
    $redis.hkeys("#{session_id}_saved").map do |key|
      JSON.parse($redis.hget("#{session_id}_saved", key))
    end
  end

  def get_cheapest_flight(festival, user)
    d = DistanceService.new
    flight_params = {
      departure_airport: user['departure_airport'] || 'yvr',
      arrival_airport: d.get_nearest_airport(festival.latitude, festival.longitude, festival.country),
      festival_id: festival.id,
      cabin_class: 'Economy',
      adults: 1,
      children: 0,
      infants: 0
      }
    festival.search_flights(flight_params)[1]
  end
  
  # TODO: refactor  
  def get_first_bus(festival, sessionId)
    usr_location = $redis.hget(sessionId, 'location').split(', ')
    depart_date = (festival.start_date - 1).strftime
    depart_from = { city: usr_location[0], state: usr_location[1] }
    return_date = (festival.end_date + 1).strftime
    return_from = { city: festival.city, state: festival.state }

    if festival.country != "CA" && festival.country != "US"
      @data = "Sorry, bus schedules are currently only available for Canada and US"
    elsif depart_from == return_from
      @data = "Festival is located in your home city. You're already there!"
    elsif Date.today > festival.end_date
      @data = "Festival has already ended. No greyhound bus schedules available."
    elsif Date.today >= festival.start_date
      @data = "Festival already in progress. No greyhound bus schedules available."
    else
      # g = GreyhoundScraper.new(depart_date, depart_from, return_date, return_from, 'Round Trip', 'phantomjs')
      # @data = g.run_depart

      ## test data
      @data = {:depart=>{0=>{:cost=>"79.00", :start_time=>"12:15AM", :end_time=>"07:40AM", :travel_time=>"7h 25m"}, 1=>{:cost=>"79.00", :start_time=>"06:30AM", :end_time=>"12:15PM", :travel_time=>"5h 45m"}, 2=>{:cost=>"88.00", :start_time=>"12:30PM", :end_time=>"05:30PM", :travel_time=>"5h 00m"}, 3=>{:cost=>"81.00", :start_time=>"02:30PM", :end_time=>"07:30PM", :travel_time=>"5h 00m"}, 4=>{:cost=>"81.00", :start_time=>"06:00PM", :end_time=>"11:45PM", :travel_time=>"5h 45m"}}, :return=>{0=>{:cost=>"", :start_time=>"08:00AM", :end_time=>"01:20PM", :travel_time=>"5h 20m"}, 1=>{:cost=>"", :start_time=>"09:15AM", :end_time=>"04:40PM", :travel_time=>"7h 25m"}, 2=>{:cost=>"", :start_time=>"12:01PM", :end_time=>"05:00PM", :travel_time=>"4h 59m"}, 3=>{:cost=>"", :start_time=>"03:30PM", :end_time=>"09:30PM", :travel_time=>"6h 00m"}, 4=>{:cost=>"", :start_time=>"11:15PM", :end_time=>"05:05AM", :travel_time=>"5h 50m"}}}

    end
    @data
  end
end
