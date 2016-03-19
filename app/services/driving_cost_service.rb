class DrivingCostService
  # this will take params/obj as an argument once search form is up
  # right now this doesn't account for ferry prices/changing mode of transportation
  # TODO: account for more specific adresses
  # TODO: account for round trip

  attr_reader :festival, :origin_city, :origin_prov, :dest_city, :dest_prov

  def initialize
    @festival = 'rifflandia'

    # these will eventually be properties of a festival obj
    @origin_city = 'Vancouver'
    @origin_prov = 'BC'
    @dest_city = 'Victoria'
    @dest_prov = 'BC'
  end

  def get_fuel_consumption
    fuel_csv = 'http://www.rncan.gc.ca/sites/www.rncan.gc.ca/files/oee/files/csv/MY2011%20Fuel%20Consumption%20Ratings%205-cycle.csv'
    cars = CSV.new(open(fuel_csv))
    all_cars = cars.select { |car| !car[-3].nil? }
    sum_all_cars = all_cars.reduce(0) do |sum, car|
      sum + car[-3].to_f
    end
    # default unit is L/100km
    sum_all_cars / all_cars.length
  end

  def get_avg_gas_price
    gasbuddy = Nokogiri::HTML(open('http://gasbuddy.com/?search=Vancouver%2C+BC'))
    gasbuddy.css('.gb-price-lg')[0].text.gsub(/\s+/, '').to_f / 100
  end

  def get_trip_dist
    origin = [@origin_city, @origin_prov].join('+')
    dest = [@dest_city, @dest_prov].join('+')

    googl_dist = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{origin}&destinations=#{dest}&key=#{ENV['GOOGL_DIS_KEY']}"
    googl_resp = HTTParty.get(googl_dist)
    googl_data = JSON.parse(googl_resp.body)
    # convert from m to km
    googl_data['rows'][0]['elements'][0]['distance']['value'] / 1000.0
  end

  def calc_driving_cost
    # use trip distance as a multiplier for fuel consumption 
    litres_needed = get_fuel_consumption * ( get_trip_dist / 100 )
    litres_needed * get_avg_gas_price
  end
end
