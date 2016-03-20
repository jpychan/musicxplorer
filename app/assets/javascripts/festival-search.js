$(function() {

  $('.date-picker').datepicker({
    minDate: new Date(),
    dateFormat: 'yy-mm-dd'
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

      $('<div>').text('Location: ' + festival.location).appendTo(festivalDiv);

      $('<div>').text(festival.description)
        .attr('data-id', festival.id)
        .addClass('festival-result')
        .appendTo(festivalDiv);

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
