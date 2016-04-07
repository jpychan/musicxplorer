MusicXplorer is a web app that helps you find music festivals around the world and show you how much it would be for you to get there. This was the final group project for the Lighthouse Labs Web Dev bootcamp. There were 4 people.

Try out the demo version: https://tranquil-tor-40216.herokuapp.com/

Tech Stack:
- Rails
- Redis
- Postgres
- PhantomJS
- Skeleton (front-end framework)


APIs Used:
- Google (Maps, Distance Services, Directions, GeoNames)
- Skyscanner
- Flickr
- Gasbuddy

Features
- Save festivals and compare the cost in an easy-to-read table
- Can set your default location
- Search database for festivals
- Shows you how much it is to drive, bus or fly to each festival

How It was Built

Data Source
Scraped a popular music festival website: musicfestivalwizard.com. ~450 festivals

My contribution to the project
- front-end design - Festival Details page and general page layout
- integration with Skyscanner API to allow users to book flights directly from our site
- imported airport data into database to find closest airports to the location of the user and festival
- Google maps - festival location and driving directions
- database cleanup - separated location data from one column to multiple columns of city, state and country, capitalized artist names, etc.

Updates:
- converted from Pure CSS framework to Skeleton for a responsive mobile experience.

