# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


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

# Festival.create(name: 'Pemberton Music Festival', start_date: '2016-07-14', end_date:'2016-07-17', location: 'Pemberton',
# city: 'Pemberton', state: 'BC', country: 'Canada', website: 'http://pembertonmusicfestival.com/',
# description: 'Grab your friends and leave the world behind for a four-day celebration beneath epic Mount Currie in Pemberton Valley. Full of dancing, food, friendship, and of course — the best music EVER!',
# price: 295, currency: 'CAD', camping: true)

# Festival.create(name: 'Shambhala Music Festival', start_date: '2016-08-05', end_date:'2016-08-08', location: 'Salmo River Ranch',
# city: 'Nelson', state: 'BC', country: 'Canada', website: 'http://www.shambhalamusicfestival.com/',
# description: 'This is Canada’s premiere Electronic Music Festival. Cutting edge Talent, Lights and Sound come together in Paradise to give life to a non -sponsored family run anomaly. Seeing it for yourself is the only way to understand exactly what is Shambhala.',
# price: 365, currency: 'CAD', camping: true)

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


FestivalGenre.create(festival_id: 1, genre_1_id: 1, genre_2_id: 2, genre_3_id: 7, genre_4_id: 5)
FestivalGenre.create(festival_id: 2, genre_1_id: 1)
FestivalGenre.create(festival_id: 3, genre_1_id: 16)  
FestivalGenre.create(festival_id: 4, genre_1_id: 6)
FestivalGenre.create(festival_id: 5, genre_1_id: 6)

