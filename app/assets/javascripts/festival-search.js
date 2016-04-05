$(function() {

  // DATE PICKER
  // set max date to account for greyhound search limit
  function maxDay() {
    var d = new Date();
    d.setDate(d.getDate() + 320);
    return d;
  }

  $('#date-picker').datepicker({
    minDate: new Date(),
    maxDate: maxDay(), 
    dateFormat: 'yy-mm-dd'
  });

  // SET USER LOCATION
  var locationInput = $('#get_location'); //form input
  $('#edit_location').on('click', function() {
    var inputBtn = $(this);

    locationInput.prop('disabled', false);
    locationInput.prop('placeholder','');
    locationInput.toggleClass('input-locked');
    locationInput.toggleClass('input-active');
    locationInput.focus();

    locationInput.on('blur', function() {
      // debugger;
      if (locationInput.val() === '') {
        $('.location-header').text('Your default location is set to:');
        $('.location-change').text('Vancouver, BC');
      }
      else {
        $('.location-header').text('Your location has been changed:');
        $('.location-change').text(locationInput.val());
      }
      
      $('#locationModal').modal('show');
      $.ajax('/usr-info',
        { type: 'GET',
          data: {usr_location: locationInput.val()},
          success: function(xhr) { 
            console.log(xhr);
          }
      });

    });
  });

  $('#search-btn').on('click', function() {
    $('#festival-search-form').slideToggle();

  });
  
  // SOULMATE AUTO-COMPLETE
  var render, select;
  render = function(term, data, type) {
    return term;
  };
  select = function(term, data, type) {
    $('#search-artist').val(term);
    $('ul#soulmate').hide();
  };

  $('#search-artist').soulmate({
    url: '/soulmate/search',
    types: ['artists'],
    renderCallback: render,
    selectCallback: select,
    minQueryLength: 2,
    maxResults: 5
  });

  // DISPLAY WHILE WAIT FOR RESULTS TO LOAD
  $('#submit-search').on('click', function(event, data) {
    $('#search-results').empty();
    $('#search-results').html('<p>Loading...</p>');
  });

  // POPULATE SEARCH RESULTS
  function formatResults(label,ele, div) {
    if (ele === null || ele === 0) {
      $('<div>').text(label + ': n/a').appendTo(div);
    }
    else {
      $('<div>').text(label + ': ' + ele).appendTo(div);
    }
  }

  $('#festival-search').on('ajax:success', function(event, data) {
    var results = $('#search-results');
    results.empty();

    if (data.length === 0) { results.text('No results found'); }

  });
});

