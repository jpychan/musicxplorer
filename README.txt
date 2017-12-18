MusicXplorer is a web app that helps you find music festivals around the world and show you how much it would be for you to get there. This was a final group project for the Lighthouse Labs Web Dev bootcamp, and I spent 10 extra days adding features, making the site mobile responsive, and refactoring code.

Try it here: https://musicxplorer.herokuapp.com/

NOTE: Skyscanner no longer provides a dev API key, so the flight search doesn't work at the moment.

Tech Stack:
- Rails
- Redis
- Postgres
- PhantomJS
- Skeleton (front-end framework)

APIs Used:
- Google (Maps, Distance Services, Directions, Places Autocomplete)
- Skyscanner
- Flickr
- Greyhound (headless browser searching and scraping bus schedules)

Features
- Save festivals and compare the cost in an easy-to-read table
- Detects your default location by your IP, user-editable
- Search through the 450 festivals around the world
- Shows you how much it is to drive, bus or fly to each festival

Data Source
Festival data: musicfestivalwizard.com.
Gas price: Gasbuddy

My updates
- made the site completely mobile responsive (converted from PureCSS to Skeleton)
- fixed caching - saving data according to user's session ID, rather than overwriting the same row by different users
- added caching to save bus and flight data to avoid API being called multiple times for the same search (expires after 30 min)
- added default location setting by user's IP
- added Google Places Autocomplete API for users to set their default location
- refactored controller
- validation for bus and flight search when the festival#show page renders rather than making a request to the database (i.e. when festival is in the past or the user is in the same city as the festival)

My contribution to the project
- front-end design - Festival Details page and general page layout
- integration with Skyscanner API to allow users to book flights directly from our site
- found data for the 500 busiest airport and imported into the database to find calculate the closest airports to the locations of the user and festival
- Google maps - festival location and driving directions
- database cleanup - separated location data from one column to multiple columns of city, state and country, capitalized artist names, etc.



