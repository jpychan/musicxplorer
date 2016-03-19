class FestivalsController < ApplicationController

  def show
    # will take params or an obj as an arg once search form is up
    driving = DrivingInfoService.new
    @festival = driving.festival
    @price_by_car = driving.calc_driving_cost
    @time_by_car = driving.get_trip_time[0]
  end

  def all  
    @genres = Genre.all    
  end

  # TODO: need to modify this based on actual data format & account for blank fields
  def festival_list
    # find festivals w/in a 500km radius [would extend into the states]
    festivals = Festival.where('start_date >= ?', params[:date]).order(:start_date)
    @festivals = festivals.select{|f| f.genres.include?( Genre.find(params[:genre]) )}
    render json: @festivals
  end

  def flickr_images
    @festival = params[:festival]
    img_src = "https://api.flickr.com/services/rest/?api_key=#{ENV['FLICKR_KEY']}&method=flickr.photos.search&text=#{@festival}&sort=relevance&per_page=10&content_type=1&format=json&nojsoncallback=1"
    response = HTTParty.get(img_src).body
    @image = JSON.parse(response)
    render json: @image 
  end

end
