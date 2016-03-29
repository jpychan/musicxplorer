$(function() {

  if ($('#festival-show').length > 0) {

    var carPrice = $('.driving-cost')[0].dataset.carPrice
    var drivingMapDiv = $('#driving-map');
    var destinationCoords = {
      lat: drivingMapDiv[0].dataset.latitude,
      long: drivingMapDiv[0].dataset.longitude
    };
    
    var departure = new google.maps.LatLng("49.246", "-123.116");

    var destination = new google.maps.LatLng(destinationCoords.lat, destinationCoords.long);
    var drivingMap;
    var map2;
    var festivalMarker;
  }

  var festivalMaps = {

  loadDrivingMap: function() {

    drivingMap = new google.maps.Map(document.getElementById('driving-map'), {
      center: departure,
      scrollwheel: false,
      zoom: 8
    });

    var directionsDisplay = new google.maps.DirectionsRenderer({
      map: drivingMap
    });



    // Set destination, origin and travel mode.
    var request = {
      destination: destination,
      origin: departure,
      travelMode: google.maps.TravelMode.DRIVING
    };

    debugger;

    // Pass the directions request to the directions service.
    var directionsService = new google.maps.DirectionsService();
    directionsService.route(request, function(response, status) {
      if (status == google.maps.DirectionsStatus.OK) {
        // Display the route on the map.
        directionsDisplay.setDirections(response);
        }
     });
   },

  loadFestivalMap: function() {

    map2 = new google.maps.Map(document.getElementById('festival-map'), {
      center: destination,
      scrollwheel: false,
      zoom: 8
    });

    festivalMarker = new google.maps.Marker({
      position: destination,
      map: map2
   });

  },

  resetDrivingMap: function() {
    google.maps.event.trigger(drivingMap, "resize");
    drivingMap.setCenter(departure);
    drivingMap.setZoom(4);
    },
  };

  if($('#festival-show').length > 0) {
    festivalMaps.loadFestivalMap();

  }

  if ($('#festival-show').length > 0 && carPrice > 0) {
    festivalMaps.loadDrivingMap();

  }
  
  // show first content by default
  $('#tabs-nav li:first-child').addClass('active');

  // click function
  $('#festival-show').on('click', '#tabs-nav li', function(event){

    event.preventDefault();

    $('#tabs-nav li').removeClass('active');
    $(this).addClass('active');
    $('.content:not(".hidden")').removeClass('active').addClass('hidden');

    var activeTab = $(this).find('a').attr('href');
    $(activeTab).removeClass('hidden').addClass('active');
    $(activeTab).fadeIn();

    if (carPrice > 0) {

      festivalMaps.resetDrivingMap();
    }

  });

  //Travel tabs
  $('#festival-show').on('click', '#travel-tabs li', function(event){

    event.preventDefault();

    $('.route-details:not(".hidden")').removeClass('active').addClass('hidden');

    var activeTravelTab = $(this).find('a')[0].dataset.div;

    $(activeTravelTab).addClass("active").removeClass("hidden");
    $(activeTravelTab).fadeIn();

    if (carPrice > 0) {

      festivalMaps.resetDrivingMap();
    }

  });
});