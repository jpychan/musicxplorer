$(function() {
  // ADD OR REMOVE FESTIVALS FROM FAVORITES ON FESTIVAL SHOW PAGE
  $('.cache-btns').on('change', '.fave-btn', function(){
    var checkbox = $('#click');

    if (checkbox.prop("checked") == true){
      var driving = $('.driving-cost');
      var tripCost = {
        festivalId: $('.music-festival').attr('data-id'),
        drivingPrice: driving.attr('data-car-price'),
        drivingTime: driving.attr('data-car-time')
      };
      $.ajax('/festival-select',
        { dataType: 'json',
          type: 'POST',
          data: tripCost
        });
    }
    else if (checkbox.prop("checked") == false){
      $.ajax('/festival-unselect',
      { dataType: 'json',
        type: 'POST', 
        data: { festivalId: $('.music-festival').attr('data-id') }
      });
      }
  });

  // REMOVE FESTIVALS FROM FESTIVAL FAVOURITES PAGE
  $('.fave-festivals').on('click', '.remove-fave', function() {
    var festivalDiv = $(this).closest('.fave');
    var data = { festivalId: festivalDiv.attr('data-id') };
    $.ajax('/festival-unselect', 
      { dataType: 'json',
        type: 'POST',
        data: data,
        complete: function() { festivalDiv.remove(); }
      });
  });

  // REFRESH FESTIVAL PARTIAL
  function buildFestival(value, row) {
    $('<td>').text(value).appendTo(row);
  }

  function displayCost(time, price, row) {
    if (time) {
      buildFestival(time, row);
      buildFestival('$'+price, row);
    }
    else {
      $('<td>').attr('colspan', '2').text('n/a').appendTo(row);
    }
  }
  function display(value) {
    if (value && value != 0) { 
      return value;
    }
    else {
      return 'n/a';
    }
  }

  // TODO: refactor!
  $('.refresh-grid').on('click', function() {
    $.ajax('/festival-subscriptions', 
      { dataType: 'json',
        success: function(data) {
          var tbody = $('.fave-festivals'); 
          tbody.empty();

          data.forEach(function(f) {
            var row = $('<tr>').addClass('fave')
                        .attr('data-id', f['id'])
                        .appendTo(tbody);
            var nameCol = $('<td>').appendTo(row);
            var link = $('<a>').attr('href', '/festivals/' + f['id'])
                               .text(f['name'])
                               .appendTo(nameCol);
            buildFestival(f['date'], row);
            buildFestival(f['location'], row);
            buildFestival(display(f['price']), row);
            buildFestival(display(f['camping']), row);

            displayCost(f['time_car'], f['price_car'], row);
            displayCost(f['time_bus'], f['price_bus'], row);
            displayCost(f['time_flight_in'], f['price_flight'], row);
            
            $('<td>').html('<button class="remove-fave"><i class="fa fa-star"></i> Remove</button>').appendTo(row);
          });
        }
      }
    );
  });

  // FLICKR
  if ($('#festival-show').length > 0) {
    var festival = $('.flickr-imgs').data('name').replace(/[^a-z0-9\s]/i, '');
    $.ajax('/flickr_images/' + festival, { dataType: 'json' }).done(function(data) { 
      if (data.stat != 'ok') { return console.log('error'); }
   
      var imgs = data.photos.photo;
      imgs.forEach(function(img) { 
        var imgSrc = 'https://farm'+img.farm+'.staticflickr.com/'+img.server+'/'+img.id+'_'+img.secret+'.jpg';
        var imageDiv = $('<div>').addClass('each-image').addClass('pure-u-2').appendTo('.flickr-imgs');
        var img = $('<img>').attr('src', imgSrc);

        imageDiv.appendTo('.flickr-imgs').append(img);
      });
    });
  }

  // BUTTON TOGGLE THE FLIGHT SEARCH FORM
  $('#festival-show').on('click', '#flight-search-btn', function() {
    $('#flight-search-form').slideToggle();
  });

  //HIDE SEARCH FORM ON SEARCH

  $("#festival-search-form").on('click', '#submit-search', function() {
    $('#festival-search-form').toggle();
  });
  
  var target = $('#wel');
  var targetHeight = target.outerHeight();

  $(window).scroll(function(){
    var scrollPercent = (targetHeight - window.scrollY) / targetHeight;
    if(scrollPercent >= 0){
      target.css('opacity', scrollPercent);
    }
  }); 

$(".map_button").click(function(){
  $("#map").toggle(300);
});

// $('.pan_button').on('click', function(){
//   var latLng = new google.maps.LatLng(49.8994, -97.1392); //should pan to specified location (based on card/div?)
//   map.panTo(latLng);


});

  // alert('hello');



function initMap() {

  var mapDiv = $('.container');
  var myLatLng = {
    lat: mapDiv[0].dataset.userlatitude,
    long: mapDiv[0].dataset.userlongitude
  };

  var userLocation = new google.maps.LatLng(myLatLng.lat, myLatLng.long);
  var mapCon = $('#map')[0];
  var map;

  map = new google.maps.Map(mapCon, {
    center: userLocation,
    zoom: 7
  });

  var marker = new google.maps.Marker({
    map: map,
    position: userLocation,
    title: 'Hello World'
  });

  $.getJSON("/festivals", function(data) {
    $.each(data, function(index, festival) {
      console.log("wat");
      console.log(google);
      console.log("the hekk");
      var marker = new google.maps.Marker({
        map: map, 
        position: {lat:festival.latitude, lng:festival.longitude}, 
        name: name
      });
      // var contentString = "This is a string";
      var infowindow = new google.maps.InfoWindow({
        content: (festival.name + ',' + ' ' + festival.date)
      });
      marker.addListener('click', function() {
        console.log("listener");
        infowindow.open(map, marker);
        infowindow.addListener('closeclick', function() {
          infowindow.close();
       });
      });
    });
  });
}   

