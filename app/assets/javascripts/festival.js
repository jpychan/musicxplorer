$(function() {
  // FLICKR
  
  $.ajax('/flickr_images', { dataType: 'json' }).done(function(data) { 
    if (data.stat != 'ok') { return console.log('error'); }
    
    var imgs = data.photos.photo;
    imgs.forEach(function(img) { 
      var imgSrc = 'https://farm'+img.farm+'.staticflickr.com/'+img.server+'/'+img.id+'_'+img.secret+'.jpg';
      $('<img>').attr('src', imgSrc).appendTo('.flickr');
    });

  });
});
