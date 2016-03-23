$(function() {

  $('.date-picker').datepicker({
    minDate: new Date(),
    dateFormat: 'yy-mm-dd'
  });

  $('#festival-search input[type=submit]').on('click', function(event, data) {
    $('#search-results').empty();
    $('#search-results').html('<p>Loading...</p>');
  });
  // POPULATE SEARCH RESULTS
  $('#festival-search').on('ajax:success', function(event, data) {
    var results = $('#search-results');
    results.empty();

    if (data.length === 0) { results.text('No results found'); }

    data.forEach(function(festival) {
      var festivalDiv = $('<div>').appendTo(results);

      $('<a>').attr('href', '/festivals/' + festival.id)
        .text(festival.name)
        .appendTo(festivalDiv);

      var festivalDetails = $('<div>').addClass('festival-result')
                              .attr('data-id', festival.id)
                              .appendTo(festivalDiv);
                              
      $('<div>').text('Location: ' + festival.location).appendTo(festivalDetails );
      $('<div>').text('Date: ' + festival.date).appendTo(festivalDetails);
      $('<div>').text('Camping: ' + festival.camping).appendTo(festivalDetails);
      if (festival.description === null) {
        $('<div>').text('Description unavailable').appendTo(festivalDiv);
      }
      else {
        $('<div>').text(festival.description).appendTo(festivalDiv);
      }
    });
  });

  // SELECT FESTIVALS
  // TODO: toggling selection
  $('#search-results').on('click', '.festival-result', function() {
    var selectedId = { festivalId: $(this).attr('data-id') };

    // TODO: maybe attach a condition to this...
    $.ajax('/festival-select',
      { dataType: 'json',
        type: 'POST',
        data: selectedId,
        success: function() { console.log('festival selected'); },
        error: function(xhr) { console.log(xhr.statusText); }
      });
  });

});
