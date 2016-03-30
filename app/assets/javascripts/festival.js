$(function() {
  // function addSearched() {
  //   for (var i = 0; i < searched.length; i++) {
  //     var ele = searched[i];
  //      $('#search-results').appendTo('#results_container'); 
  //    };
  //   };


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
        type: 'DELETE', 
        data: { festivalId: $('.music-festival').attr('data-id') }
      });
      }
  });

  // $('.cache-btns').on('click', '.fave-btn',function() {
  //   var driving = $('.driving-cost');
  //   var tripCost = {
  //     festivalId: $('.music-festival').attr('data-id'),
  //     drivingPrice: driving.attr('data-car-price'),
  //     drivingTime: driving.attr('data-car-time')
  //   };
  //   $.ajax('/festival-select',
  //     { dataType: 'json',
  //       type: 'POST',
  //       data: tripCost
  //     });
  //   $(this).replaceWith('<button class="remove-btn">Remove from Favourites</button>');
  // });

  // $('.cache-btns').on('click', '.remove-btn', function() {
  //   $(this).replaceWith('<button class="fave-btn">Add to Favourites</button>');
  //   $.ajax('/festival-unselect',
  //     { dataType: 'json',
  //       type: 'DELETE', 
  //       data: { festivalId: $('.music-festival').attr('data-id') }
  //     });
  // });

  // REMOVE FESTIVALS FROM FESTIVAL FAVOURITES PAGE
  $('.remove-fave').on('click', function() {
    var festivalDiv = $(this).closest('.fave-festival');
    var data = { festivalId: festivalDiv.attr('data-id') };
    $.ajax('/festival-unselect', 
      { dataType: 'json',
        type: 'POST',
        data: data,
        complete: function() { festivalDiv.remove(); }
      });
  });

  // FLICKR
  if ($('#festival-show').length > 0) {

    var festival = $('.flickr-imgs').data('name');
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

  
  
 // var map;
 //      function initMap() {
 //        map = new google.maps.Map(document.getElementById('map'), {
 //          center: {lat: -34.397, lng: 150.644},
 //          zoom: 8
 //        });
 //      }
 // }


});

function initMap() {
  var myLatLng = {lat: 49.2827, lng: -123.1207};
  var map;

  map = new google.maps.Map(document.getElementById('map'), {
    center: myLatLng,
    zoom: 7
  });

  var marker = new google.maps.Marker({
    map: map,
    position: myLatLng,
    title: 'Hello World'
  });

  $.getJSON("/festivals", function(data) {
    $.each(data, function(index, festival) {
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
    // setTimeout(function(){
    //   infowindow.close();
    // },3000)
    });
  });
});

$(".map_button").click(function(){
  $("#map").toggle(300);
});

$('.pan_button').on('click', function(){
  var latLng = new google.maps.LatLng(49.8994, -97.1392); //should pan to specified location (based on card/div?)
  map.panTo(latLng);
});
}

