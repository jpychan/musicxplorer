$(function() {

  $('.date-picker').datepicker({ 
    minDate: new Date(),
    dateFormat: 'yy-mm-dd'
  });

  $('#festival-search').on('ajax:success', function(event, data) {
    var results = $('#search-results');
    results.empty();
    
    if (data.length === 0) { results.text('No results found'); }
    console.log(data);
    data.forEach(function(festival) {
      $('<div>').text(festival.name).appendTo(results);
    });
  });

});
