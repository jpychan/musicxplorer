class FestivalsController < ApplicationController

  def show
    # right now this doesn't account for ferry prices/changing mode of transportation
    # TODO: account for more specific addresses!
    # TODO: account for round trip
    @festival = 'rifflandia'
    # these will eventually be properties of a festival
    @origin_city = 'Vancouver'
    @origin_prov = 'BC'
    @dest_city = 'Victoria'
    @dest_prov = 'BC'
    origin = [@origin_city, @origin_prov].join('+')
    dest = [@dest_city, @dest_prov].join('+')
    
    fuel_csv = 'http://www.rncan.gc.ca/sites/www.rncan.gc.ca/files/oee/files/csv/MY2011%20Fuel%20Consumption%20Ratings%205-cycle.csv'
    cars = CSV.new(open(fuel_csv))
    all_cars = cars.select { |car| !car[-3].nil? }
    sum_all_cars = all_cars.reduce(0) do |sum, car|
      sum + car[-3].to_f
    end
    avg_fuel_consumption = sum_all_cars / all_cars.length
  
    gasbuddy = Nokogiri::HTML(open('http://gasbuddy.com/?search=Vancouver%2C+BC'))
    avg_gas_price = gasbuddy.css('.gb-price-lg')[0].text.gsub(/\s+/, '').to_f / 100
    
    googl_dist = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{origin}&destinations=#{dest}&key=#{ENV['GOOGL_DIS_KEY']}"
    googl_resp = HTTParty.get(googl_dist)
    googl_data = JSON.parse(googl_resp.body)
    distance = googl_data['rows'][0]['elements'][0]['distance']['value'] / 1000.0    
    litres_needed = avg_fuel_consumption * (distance / 100)
    @price_by_car = avg_gas_price * litres_needed
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
