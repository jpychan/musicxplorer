# Genre.create(genre_type: 'electronic')
# Genre.create(genre_type: 'rock')
# Genre.create(genre_type: 'indie')
# Genre.create(genre_type: 'jam')
# Genre.create(genre_type: 'metal')
# Genre.create(genre_type: 'country')
# Genre.create(genre_type: 'hip hop')
# Genre.create(genre_type: 'bluegrass')
# Genre.create(genre_type: 'jazz')
# Genre.create(genre_type: 'folk')
# Genre.create(genre_type: 'latin')
# Genre.create(genre_type: 'reggae')
# Genre.create(genre_type: 'classical')
# Genre.create(genre_type: 'r&b')
# Genre.create(genre_type: 'world music')

# Festival.create(name: 'Pemberton Music Festival', start_date: Date.new(2016,7,14), end_date: Date.new(2016,7,17), location: 'Pemberton',
#  city: 'Pemberton', state: 'BC', country: 'Canada', website: 'http://pembertonmusicfestival.com/',
#  description: 'Grab your friends and leave the world behind for a four-day celebration beneath epic Mount Currie in Pemberton Valley. Full of dancing, food, friendship, and of course — the best music EVER!',
#  price: 295, currency: 'CAD', camping: true)
#
# Festival.create(name: 'Shambhala Music Festival', start_date: Date.new(2016,8,5), end_date: Date.new(2016,8,8), location: 'Salmo River Ranch',
#  city: 'Nelson', state: 'BC', country: 'Canada', website: 'http://www.shambhalamusicfestival.com/',
#  description: 'This is Canada’s premiere Electronic Music Festival. Cutting edge Talent, Lights and Sound come together in Paradise to give life to a non -sponsored family run anomaly. Seeing it for yourself is the only way to understand exactly what is Shambhala.',
#  price: 365, currency: 'CAD', camping: true)
#
# FestivalGenre.create(festival_id: Festival.first.id, genre_id: 1)
# FestivalGenre.create(festival_id: Festival.first.id, genre_id: 2)
# FestivalGenre.create(festival_id: Festival.last.id, genre_id: 3)

# Festival.create(name: 'Rifflandia', start_date: '2016-09-15', end_date:'2016-09-18',
# city: 'Victoria', state: 'BC', country: 'Canada', website: 'http://rifflandia.com/', location: 'Victoria',
# description: "Every September Rifflandia Festival transforms the city of Victoria into one big musical buffet, with over 100 performances on 10 stages, all within walking distance in the city's beautiful and historic downtown core.
# Rifflandia Festival has quickly become one of Western Canada’s most exciting annual music events, featuring a truly diverse line-up of acclaimed Canadian and International artists. Past highlights include Aesop Rock, Beach House, Black Mountain, Gord Downie, Lee Ranaldo, Tegan and Sara, Z-Trip and many more.",
# price: 100, currency: 'CAD', camping: false)

# Festival.create(name: 'Sunfest Country Music Festival', start_date: '2016-07-28', end_date:'2016-07-31',
# city: 'Cowichan Valley', state: 'BC', country: 'Canada', website: 'http://sunfest.com/', location: 'Cowichan Valley',
# description: "Sunfest welcomes world class entertainment each and every year, and continues to find ways to showcase local artists, donate partial proceeds to local organizations,
# and maximize the economic benefit and exposure for the Cowichan Valley and Vancouver Island.On August long weekend Sunfest attracts thousands of Country music fans from all over
# the island, the province and now boasts an international fan base.  Sunfest is more than just a concert, it’s a vacation destination. Thousands of  people will be attending the
# biggest Sunfest yet during the hottest weekend of the Summer!", price: 229, currency: 'CAD', camping: true)

# Festival.create(name: "Merritt Rockin' River Fest", start_date: '2016-07-28', end_date:'2016-07-31',
# city: 'Merritt', state: 'BC', country: 'Canada', website: 'http://rockinriverfest.com/', location: 'Merritt',
# description: "Get ready for 4 days of country this summer with Sam Hunt, Dean Brody, Randy Houser, John Michael Montgomery, The Road Hammers,
# High Valley and many more amazing artists! Don't miss the best festival of the summer on the most beautiful show site in the world from July
#  28th to 31st in Merritt, BC! It's going to be an amazing year meeting new friends and old as we chill in the
#  Coldwater River during the day and party it up all night with amazing music!", price: 265, currency: 'CAD', camping: true)


#FestivalGenre.create(festival_id: 1, genre_1_id: 1, genre_2_id: 2, genre_3_id: 7, genre_4_id: 5)
#FestivalGenre.create(festival_id: 2, genre_1_id: 1)
#FestivalGenre.create(festival_id: 3, genre_1_id: 16)
#FestivalGenre.create(festival_id: 4, genre_1_id: 6)
#FestivalGenre.create(festival_id: 5, genre_1_id: 6)

# TODO: refactor!
def extract_data
  #page = to_nokogiri(get_the_body('https://www.musicfestivalwizard.com/music-festival-map'))
  page = get_the_body('https://www.musicfestivalwizard.com/music-festival-map')
  festival_info = []
  page.css('.marker').each do |marker|
    data = {}
    data[:lat] = marker.attributes["data-lat"].value
    data[:lng] = marker.attributes["data-lng"].value
    data[:city] = marker.css('p')[0].children.text
    data[:date] = marker.css('p')[1].children.text
    data[:start_date] = format_date(marker)
    data[:event] = get_event_name(marker)

    url = marker.children.css('.gm-infowindow a:first-child')[0]['href']
    details = get_the_body(url)
    festival = details.css('#festival-basics').children.select do |line|
        (line.name == 'text' || line.name == 'a') && !line.text.start_with?("\r\n")
      end

    data[:price] = festival[2].text if festival[2]
    data[:camping] = festival[3].text if festival[3]
    data[:website] = festival[4]['href'] if festival[4]
    data[:description] = festival[5].text if festival[5]
    data[:artists] = details.css('.lineupguide li').map { |artist| artist.text.capitalize if artist.text }

    festival_info << data
  end
  festival_info
end

def format_date(marker)
  date = marker.css('p')[1].children.text
  date_arr = date.gsub(/\-\w+/, '').gsub(',', '').split(' ')
  months = ['January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December']
  find_month = months.index(date_arr.shift)
  month_num = find_month ? find_month + 1 : 1
  Date.new(date_arr.last.to_i, month_num, date_arr.first.to_i)
end

def get_event_name(marker_obj)
   marker_obj.css('a:nth-child(2)')[0].children.text
end

#def to_nokogiri(body)
# Nokogiri::HTML(body)
#end

def get_the_body(url)
 body = HTTParty.get(url)
 Nokogiri::HTML(body)
end

extract_data.each do |i|
  f = Festival.create(
    name: i[:event],
    latitude: i[:lat].to_f,
    longitude: i[:lng].to_f,
    location: i[:city],
    start_date: i[:start_date],
    date: i[:date],
    website: i[:website],
    description: i[:description],
    price: i[:price],
    camping: i[:camping]
    )
  # here to reassure myself data is being saved to db
  puts f.name

  i[:artists].each do |artist|
    a = Artist.find_or_create_by(name: artist)
    Performance.create(artist_id: a.id, festival_id: f.id)
  end
end
