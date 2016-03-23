class FestivalsController < ApplicationController
  SEARCH_RADIUS = 500
  TOO_FAR = SEARCH_RADIUS + 1   # value if ZERO_RESULTS returned in google distance matrix API
  IN_RANGE = SEARCH_RADIUS - 1

  def show
    # will take params or an obj as an arg once search form is up
    @festival = Festival.includes(:artists, :genres).find(params[:id])
    driving = DrivingInfoService.new(@festival)
    @price_by_car = driving.calc_driving_cost
    @time_by_car = driving.get_trip_time[0]
  end

  def all
    @artists = Artist.all.order(:name)
    @genres = Genre.all.order(:name)
    #selected = $redis.hgetall({}
    # $redis.hkeys({}).each do |key|
    #   $redis.hget({}, key)
    # end
    #@selected_festival = selected
  end

  def festival_list
   festivals = Festival.joins("inner join performances as p on p.festival_id = festivals.id inner join artists as a on p.artist_id = a.id inner join festival_genres as fg on fg.festival_id = festivals.id inner join genres as g on fg.genre_id = g.id").where('start_date >= ? AND LOWER(camping) LIKE ? AND g.name LIKE ? AND a.name LIKE ?', params[:date], "%#{params[:camping]}%", "%#{params[:genre]}%", "%#{params[:artist]}%").distinct
    @festivals = festivals.select do |f|
      d = DistanceService.new(params[:location], f)
      dist_km = d.calc_distance
      dist_km <= SEARCH_RADIUS
    end
    render json: @festivals
  end

  def festival_compare
  end

  def festival_select
    ftstival = Festival.find(params[:festivalId])
    festival_json = festival.to_json
    if festival
      #$redis.hset({}, festival.id, festival_json)
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
