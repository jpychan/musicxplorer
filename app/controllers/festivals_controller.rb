class FestivalsController < ApplicationController

  def show
    # will take params or an obj as an arg once search form is up
    driving = DrivingCostService.new
    @festival = driving.festival
    @price_by_car = driving.calc_driving_cost
  end

  def all  
    
  end

  def flickr_images
    @festival = params[:festival]
    img_src = "https://api.flickr.com/services/rest/?api_key=#{ENV['FLICKR_KEY']}&method=flickr.photos.search&text=#{@festival}&sort=relevance&per_page=10&content_type=1&format=json&nojsoncallback=1"
    response = HTTParty.get(img_src).body
    @image = JSON.parse(response)
    render json: @image 
  end

end
