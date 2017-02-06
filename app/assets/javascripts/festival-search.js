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
  var userInput = {};
  $('#edit_location').on('click', function() {

    locationInput.prop('disabled', false);
    locationInput.prop('placeholder','');
    locationInput.toggleClass('input-locked');
    locationInput.toggleClass('input-active');
    locationInput.focus();

    locationInput
      .geocomplete({types: ['(cities)']})
      .bind("geocode:result", function(event, result){

        var addresses = result.address_components;
        userInput.formatted_address = result.formatted_address;
        userInput.lat = result.geometry.location.lat();
        userInput.lng = result.geometry.location.lng();

        addresses.forEach(setAddress);

        if (locationInput.val() === '') {
        $('.location-header').text('Your default location is set to:');
        $('.location-change').text('Vancouver, BC');
        }
        else {
          $('.location-header').text('Your location has been changed:');
          $('.location-change').text(userInput.formatted_address);
        };

        $('.container').attr('data-userlatitude', userInput.lat);
        $('.container').attr('data-userlongitude', userInput.lng);
        $('search_location').attr('value', userInput.formatted_address);
        $('#search_lat').attr('value', userInput.lat);
        $('#search_long').attr('value', userInput.lng);

        locationInput.removeClass('input-active');
        locationInput.addClass('input-locked');
        locationInput.prop('disabled', true);

        $('#locationModal').modal('show');
        $.ajax('/usr-info',
          { type: 'GET',
            data: {usr_location: userInput},
            success: function(xhr) {
              console.log('ok');
          }
      });
    });
  });

  //Set Search Form Location
  var searchLocationInput = $('#search_location');

  searchLocationInput
    .geocomplete({types: ['(cities)']})
    .bind("geocode:result", function(event, result){

      var addresses = result.address_components;
      userInput.formatted_address = result.formatted_address;
      userInput.lat = result.geometry.location.lat();
      userInput.lng = result.geometry.location.lng();

      $('#search_lat').attr('value', userInput.lat);
      $('#search_long').attr('value', userInput.lng);
    });


  $('#search-btn').on('click', function() {
    $('#festival-search-form').slideToggle();

  });

  // SOULMATE AUTO-COMPLETE
  var render, select, festivalRender, festivalSelect;
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

  function setAddress(element, index, array) {
    // debugger;
    if (element.types.includes("locality")) {
      userInput.city = element.long_name;
    }
    else if (element.types.includes("administrative_area_level_1")) {
      userInput.state = element.short_name;
    }
    else if (element.types.includes("country")) {
       userInput.country = element.short_name;
    }

  };


});

