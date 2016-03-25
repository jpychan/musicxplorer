class FestivalsController < ApplicationController
  SEARCH_RADIUS = 500
  TOO_FAR = SEARCH_RADIUS + 1   # value if ZERO_RESULTS returned in google distance matrix API
  IN_RANGE = SEARCH_RADIUS - 1

  def show
    # will take params or an obj as an arg once search form is up
    @festival = Festival.find(params[:id])
    driving = DrivingInfoService.new(@festival)
    @price_by_car = driving.calc_driving_cost
    @time_by_car = driving.get_trip_time[0]
  end

  def all
    @artists = Artist.all.order(:name)
    @genres = Genre.all.order(:name)
    @selected_festivals = []   # temporarily here to not break the views
    #@selected_festivals = $redis.hkeys({}).map do |key|
    #  JSON.parse($redis.hget({}, key))
    #end
  end

  def get_usr_coordinates
    d = DistanceService.new
    d.get_usr_location(params[:usr_location])
    redirect_to root_path
  end

  # GET FESTIVAL SEARCH RESULTS
  def festival_list
    festivals = Festival.joins("INNER JOIN performances AS p ON p.festival_id = festivals.id INNER JOIN artists AS a ON p.artist_id = a.id INNER JOIN festival_genres AS fg ON fg.festival_id = festivals.id INNER JOIN genres AS g ON fg.genre_id = g.id").where('start_date >= ? AND LOWER(camping) LIKE ? AND g.name LIKE ? AND a.name LIKE ?', params[:date], "%#{params[:camping]}%", "%#{params[:genre]}%", "%#{params[:artist]}%").distinct

    d = DistanceService.new
    origin = $redis.hgetall('user')
    @festivals = festivals.select do |f|
      dist_km = d.calc_distance(origin, f)
      puts dist_km
      dist_km <= SEARCH_RADIUS
    end
    render json: @festivals
  end

  def festival_compare
  end

  def festival_select
    festival = Festival.find(params[:festivalId])
    #festival_json = festival.to_json
    
    driving = DrivingInfoService.new(festival)
    @price_by_car = driving.calc_driving_cost
    @time_by_car = driving.get_trip_time[0]
    if festival
    #  $redis.hset({}, festival.id, festival_json)
    end
    redirect_to root_path
  end

  def flickr_images 
    festival = params[:festival].gsub(/\s\d{4}/, '')
    @festival = Festival.find_by(name: params[:festival])
  img_src = "https://api.flickr.com/services/rest/?api_key=#{ENV['FLICKR_KEY']}&method=flickr.photos.search&tags=festival&text=#{festival}&sort=relevance&per_page=10&content_type=1&format=json&nojsoncallback=1"
    response = HTTParty.get(img_src).body
    @image = JSON.parse(response)
    render json: @image
  end

  def parse_all
    render json: Festival.all, content_type: "application/json"
  end
end
