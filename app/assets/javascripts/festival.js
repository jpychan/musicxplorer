$(function() {

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

//  $("#departure_airport").autocomplete({
//    delay: 500,
//    minLength: 3,
//    source: airports,
//    select: function(event, ui) {
//      $('#departure_airport').val(ui.item.value);
//    }
//  })
//  .data( "ui-autocomplete" )._renderItem = function( ul, item ) {
//            return $( "<li>" )
//            .append( "<a>" + item.label + "<br>" + item.value + "</a>" )
//            .appendTo( ul );
//         };
//
 
  // FLICKR
  if ($('.festival-details').length > 0) {
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
     // console.log(data)
     $.each(data, function(index, festival) {
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
  }
