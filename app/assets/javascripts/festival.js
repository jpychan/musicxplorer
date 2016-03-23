$(function() {
  
  // FLICKR
  var festival = $('.flickr-imgs').data('name');
  $.ajax('/flickr_images/' + festival, { dataType: 'json' }).done(function(data) { 
    if (data.stat != 'ok') { return console.log('error'); }
    
    var imgs = data.photos.photo;
    imgs.forEach(function(img) { 
      var imgSrc = 'https://farm'+img.farm+'.staticflickr.com/'+img.server+'/'+img.id+'_'+img.secret+'.jpg';
      $('<img>').attr('src', imgSrc).appendTo('.flickr-imgs');
    });
  });

});


var myLatLng = {lat: 49.2827, lng: -123.1207};
var map;

function initMap() {
    map = new google.maps.Map(document.getElementById('map'), {
    center: myLatLng,
    zoom: 7
  });

var marker = new google.maps.Marker({
    map: map,
    position: myLatLng,
    title: 'Hello World'
  });
};

$.getJSON("/festivals", function(data) {
  // console.log(data)
  $.each(data, function(index, festival) {
    console.log(festival)
    var marker = new google.maps.Marker ({
      map: map, 
      position: {lat:festival.latitude, lng:festival.longitude}, 
      name: name
    });
    var contentString = "This is a string";
    var infowindow = new google.maps.InfoWindow({
      content: (festival.name + ',' + ' ' + festival.date)
    });
    marker.addListener('click', function() {
      infowindow.open(map, marker);
      infowindow.addListener('closeclick', function() {
        infowindow.close();
      });
      // setTimeout(function(){
      //   infowindow.close();
      // },3000)
    })
  });
});


// var map = new google.maps.Map(document.getElementById('map'), {
//   center: myLatLng,
//   zoom: 8
// });
// function placeMarker(lat, lng, title) {
//   // TODO: Places a marker in the map based on lat and lng
//   var marker = new google.maps.Marker({
//     map: map,
//     position: {lat, lng},
//     title: title
//   });
// }

// arrayOfFestivals = [{name: 'hello', lat: 220, lng: 450}, {name: 'hello', lat: 220, lng: 450}]
// function placeFestvialMarkers(arrayOfFestivals) {
//   // TODO: Places a marker in the map based on lat and lng
//   for (int i=0;i< arrayOfFestivals.length;i++) {
//     placeMarker(arrayOfFestivals[i].latitude, arrayOfFestivals[i].longitude, arrayOfFestivals[i].title);
//   }
// }
