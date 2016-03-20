class FestivalsController < ApplicationController
  SEARCH_RADIUS = 500

  def show
    # will take params or an obj as an arg once search form is up
    @festival = Festival.find(params[:id])
    driving = DrivingInfoService.new(@festival)
    @price_by_car = driving.calc_driving_cost
    @time_by_car = driving.get_trip_time[0]
  end

  def all
    @genres = Genre.all
  #  selected = $redis.get('selected');
  #  @selected_festival = selected
  end

  # TODO: need to modify this based on actual data format
  # select festival distance <= 500km [one way]
  def festival_list
    origin = [ params[:city],params[:state] ].join('+')
    festivals = Festival.where('date >= ?', params[:date]).order(:date)
    @festivals = festivals.select do |f|
        dest = [ f.city, f.state ].join('+')

        googl_dist = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{origin}&destinations=#{dest}&key=#{ENV['GOOGL_DIST_KEY']}&avoid=tolls"
        resp = HTTParty.get(googl_dist).body
        results = JSON.parse(resp)
        dist_km = results['rows'][0]['elements'][0]['distance']['value'] / 1000.0
        dist_km <= SEARCH_RADIUS && f.genres.include?( Genre.find(params[:genre]) )
      end
    render json: @festivals
  end

  def festival_compare
  end

  def festival_select
    festival = Festival.find(params[:festivalId]).to_json
    if festival
  #    $redis.set('selected', festival)
    end
    redirect_to root_path
  end

  def flickr_images
    @festival = params[:festival].gsub(/\s\d{4}/, '')
    img_src = "https://api.flickr.com/services/rest/?api_key=#{ENV['FLICKR_KEY']}&method=flickr.photos.search&text=#{@festival}&sort=relevance&per_page=10&content_type=1&format=json&nojsoncallback=1"
    response = HTTParty.get(img_src).body
    @image = JSON.parse(response)
    render json: @image
  end

end
