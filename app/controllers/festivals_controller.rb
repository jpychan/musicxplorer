class FestivalsController < ApplicationController
  SEARCH_RADIUS = 500
  TOO_FAR = SEARCH_RADIUS + 1   # value if ZERO_RESULTS returned in google distance matrix API

  def show
    # will take params or an obj as an arg once search form is up
    @festival = Festival.find(params[:id])
    driving = DrivingInfoService.new(@festival)
    @price_by_car = driving.calc_driving_cost
    @time_by_car = driving.get_trip_time[0]
  end

  def all
    @artists = Artist.all.order(:name)
  #  selected = $redis.get('selected');
  #  @selected_festival = selected
  end

  # select festival distance <= 500km [one way]
  # TODO: refactor
  def festival_list
    origin = params[:location] == '' ? 'Vancouver+BC' : params[:location].gsub(/,/, '').split(' ').join('+')
    camping = params[:camping] == 'any' ? '%' : params[:camping]

    festivals = Festival.where('start_date >= ? AND LOWER(camping) LIKE ?', params[:date], camping).order(:start_date)
    @festivals = festivals.select do |f|
        dest = [f.latitude.to_f, f.longitude.to_f].join(',')

        googl_dist = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{origin}&destinations=#{dest}&key=#{ENV['GOOGL_DIST_KEY']}&avoid=tolls"
        resp = HTTParty.get(googl_dist).body
        results = JSON.parse(resp)['rows'][0]['elements'][0]

        dist_km = results['status'] != 'ZERO_RESULTS' ? (results['distance']['value'] / 1000.0) : TOO_FAR
        find_artist = params[:artist] == '' ? true : f.artists.include?( Artist.find(params[:artist]) )
        dist_km <= SEARCH_RADIUS && find_artist
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
