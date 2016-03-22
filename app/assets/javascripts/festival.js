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
    }

  $("#departure_airport").autocomplete({
    delay: 500,
    minLength: 3,
    source: airports,
    select: function(event, ui) {
      $('#departure_airport').val(ui.item.value);
    }
  })
  .data( "ui-autocomplete" )._renderItem = function( ul, item ) {
            return $( "<li>" )
            .append( "<a>" + item.label + "<br>" + item.value + "</a>" )
            .appendTo( ul );
         };

});


