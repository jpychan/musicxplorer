require 'csv'

csv_text = File.read(Rails.root.join('db', 'large_airports.csv'))
csv = CSV.parse(csv_text, :headers => true)
csv.each do |row|
  t = Airport.new
  t.name = row['name']
  t.latitude = row['latitude']
  t.longitude = row['longitude']
  t.city = row['city']
  t.country = row['country']
  t.iata_code = row['iata_code']
  t.save

  puts "#{t.name} saved"
end

puts 'Done!'