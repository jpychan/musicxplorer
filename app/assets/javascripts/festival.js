$(function() {
  $('.fave-btn').on('click', function() {
    var flight = $('#flight-search-details');
    var driving = $('.driving-cost');
    var tripCost = {
      festivalId: $('.music-festival').attr('data-id'),
      flightPrice: flight.attr('data-cheapest-flight'),
      flightTimeIn: flight.attr('data-flight-time-in'),
      flightTimeOut: flight.attr('data-flight-time-out'),
      drivingPrice: driving.attr('data-car-price'),
      drivingTime: driving.attr('data-car-time')
    };
    $.ajax('/festival-select',
      { dataType: 'json',
        type: 'POST',
        data: tripCost
      }
    );
  });
  // var userLocation = new Promise(function(resolve, reject) {
  //   navigator.geolocation.getCurrentPosition(function(position) {
  //     var coordinates = {lat:position.coords.latitude, long:position.coords.longitude};
  //     resolve(coordinates);
  //    });
  //   });

  var airports = function(request, response) {
      $.getJSON("/autocomplete", {
        query: request.term,
      }, function(data) {
        // data is an array of objects and must be transformed for autocomplete to use
        var array = data.error ? [] : $.map(data, function(m) {
          return {
            label: m.name,
            value: m.code
          };
        });
        return response(array);
      });
    };

  //Load Driving Directions
  var drivingMapDiv = $('#travel-tabs').find('#map');
  var destinationCoords = {
    lat: drivingMapDiv[0].dataset.latitude,
    long: drivingMapDiv[0].dataset.longitude
  };

  var departure = new google.maps.LatLng(49.246, -123.116);

  var destination = new google.maps.LatLng(destinationCoords.lat, destinationCoords.long);
  var map;
  var map2;
  var festivalMarker;

  var festivalMaps = {

    loadDrivingMap: function() {

      map = new google.maps.Map(document.getElementById('map'), {
        center: departure,
        scrollwheel: false,
        zoom: 8
      });

      var directionsDisplay = new google.maps.DirectionsRenderer({
        map: map
      });

      // Set destination, origin and travel mode.
      var request = {
        destination: destination,
        origin: departure,
        travelMode: google.maps.TravelMode.DRIVING
      };

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
    google.maps.event.trigger(map, "resize");
    map.setCenter(departure);
    map.setZoom(4);
    },
  };
  

  // show first content by default
  $('#tabs-nav li:first-child').addClass('active');

  // click function
  $('#festival-show').on('click', '#tabs-nav li', function(event){
    map2 = null;

    $("#festival-map").empty();


    event.preventDefault();

    $('#tabs-nav li').removeClass('active');
    $(this).addClass('active');
    $('.content:not(".hidden")').removeClass('active').addClass('hidden');

    var activeTab = $(this).find('a').attr('href');
    $(activeTab).removeClass('hidden').addClass('active');
    $(activeTab).fadeIn();

   festivalMaps.resetDrivingMap();

   if (activeTab === "#overview") {
   festivalMaps.loadFestivalMap();
    }

  });

  $('#festival-show').on('click', '#travel-tab', function(event){

  });

  //Travel tabs
  $('#festival-show').on('click', '#travel-tabs li', function(event){

    event.preventDefault();

    $('.route-details:not(".hidden")').removeClass('active').addClass('hidden');

    var activeTravelTab = $(this).find('a')[0].dataset.div;

    $(activeTravelTab).addClass("active").removeClass("hidden");
    $(activeTravelTab).fadeIn();

    festivalMaps.resetDrivingMap();
  });


  $('#festival-show').on('click', '#flight-search-btn', function() {
    $('#flight-search-form').slideToggle(200);

  });


  // FLICKR
  if ($('#festival-show').length > 0) {
    festivalMaps.loadFestivalMap();
    festivalMaps.loadDrivingMap();

    var festival = $('.flickr-imgs').data('name');
    $.ajax('/flickr_images/' + festival, { dataType: 'json' }).done(function(data) { 
      if (data.stat != 'ok') { return console.log('error'); }
   
      var imgs = data.photos.photo;
      imgs.forEach(function(img) { 
        var imgSrc = 'https://farm'+img.farm+'.staticflickr.com/'+img.server+'/'+img.id+'_'+img.secret+'.jpg';
        $('<img>').attr('src', imgSrc).appendTo('.flickr-imgs');
      });
    });
  }

  if ($('#flight-search-details').length > 0 ) {

     $("#departure_airport").autocomplete({
       delay: 500,
       minLength: 3,
       source: airports,
       select: function(event, ui) {
         $('#departure_airport').val(ui.item.value);
       }
     })
     .data( "ui-autocomplete" )._renderItem = function( ul, item ) {
               return $( "<li>" )
               .append( "<a>" + item.label + "<br>" + item.value + "</a>" )
               .appendTo( ul );
            };

     $("#arrival_airport").autocomplete({
     delay: 500,
     minLength: 3,
     source: airports,
     select: function(event, ui) {
       $('#departure_airport').val(ui.item.value);
       }
     })
     .data( "ui-autocomplete" )._renderItem = function( ul, item ) {
               return $( "<li>" )
               .append( "<a>" + item.label + "<br>" + item.value + "</a>" )
               .appendTo( ul );
            };

  }

});
