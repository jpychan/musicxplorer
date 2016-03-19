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
      var festivalDiv = $('<div>').addClass('festival-result').appendTo(results);
      festivalDiv.attr('data-id', festival.id);

      $('<a>').attr('href', '/festivals/' + festival.id)
        .text(festival.name)
        .appendTo(festivalDiv);

      $('<div>').text(festival.description).appendTo(festivalDiv);
      
    });
  });

  // SELECT FESTIVALS
  $('#search-results').on('click', '.festival-result', function() {
    var selectedId = { festivalId: $(this).attr('data-id') };

    $.ajax('/festival-select', 
      { dataType: 'json', 
        type: 'POST', 
        data: selectedId,
        success: function() { console.log('festival selected'); },
        error: function(xhr) { console.log(xhr.statusText); }
      });
  });

});
