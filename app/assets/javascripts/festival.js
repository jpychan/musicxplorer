$(function() {
  // console.log("inside function")
  // var airports = function(request, response) {
  //   $.getJSON("/autocomplete", {
  //     query: request.term,
  //   }, function(data) {
  //     // data is an array of objects and must be transformed for autocomplete to use
  //     var array = data.error ? [] : $.map(data, function(m) {
  //       return {
  //         label: m.name,
  //         value: m.code
  //       };
  //     });
  //     return response(array);
  //   });
  // };

 // $("#departure_airport").autocomplete({
 //   delay: 500,
 //   minLength: 3,
 //   source: airports,
 //   select: function(event, ui) {
 //     $('#departure_airport').val(ui.item.value);
 //   }
 // })
 // .data( "ui-autocomplete" )._renderItem = function( ul, item ) {
 //           return $( "<li>" )
 //           .append( "<a>" + item.label + "<br>" + item.value + "</a>" )
 //           .appendTo( ul );
 //        };

 
  // FLICKR
  // if ($('.festival-details').length > 0) {
  //   var festival = $('.flickr-imgs').data('name');
  //   $.ajax('/flickr_images/' + festival, { dataType: 'json' }).done(function(data) { 
  //     if (data.stat != 'ok') { return console.log('error'); }
      
  //     var imgs = data.photos.photo;
  //     imgs.forEach(function(img) { 
  //       var imgSrc = 'https://farm'+img.farm+'.staticflickr.com/'+img.server+'/'+img.id+'_'+img.secret+'.jpg';
  //       $('<img>').attr('src', imgSrc).appendTo('.flickr-imgs');
  //     });
  //   });
  // }

  console.log("outside function")
  window.initMap = function initMap() {
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
        console.log(".each")
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
          console.log("listener")
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

    $(".map_button").click(function(){
    $("#map").toggle(300);
    });

      $('.pan_button').on('click', function(){
      var latLng = new google.maps.LatLng(49.8994, -97.1392); //should pan to specified location (based on card/div?)
      map.panTo(latLng);
      });
    }
   
    var target = $('#wel');
    var targetHeight = target.outerHeight();

    $(window).scroll(function(){
      var scrollPercent = (targetHeight - window.scrollY) / targetHeight;
      if(scrollPercent >= 0){
        target.css('opacity', scrollPercent);
      }
    }); 
  });

// });

 // var map;
 //      function initMap() {
 //        map = new google.maps.Map(document.getElementById('map'), {
 //          center: {lat: -34.397, lng: 150.644},
 //          zoom: 8
 //        });
 //      }
