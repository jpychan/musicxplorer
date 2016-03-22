$(function() {

  $("#departure_airport").autocomplete({
        delay: 500,
        minLength: 3,
        source: function(request, response) {
          $.getJSON("/autocomplete", {
            query: request.term,
          }, function(data) {
            // data is an array of objects and must be transformed for autocomplete to use
            debugger;
            var array = data.error ? [] : $.map(data, function(m) {
              return {
                label: m.name,
                value: m.code
              };
            });
            response(array);
          });
        },
        focus: function(event, ui) {
          // prevent autocomplete from updating the textbox
          event.preventDefault();
        },
        select: function(event, ui) {
          // prevent autocomplete from updating the textbox
          event.preventDefault();
          // navigate to the selected item's url
          window.open(ui.item.url);
        }
      });
    });

  // $('#departure_airport').on('keyup', function() {
  //   input = $(this).val();

  //   if (input.length > 2) {
  //     console.log("2 or more!");
  //     $.ajax({
  //       type: "GET",
  //       url: "/autocomplete",
  //       data: { query: input },
     
  //       success: function(data) {
  //         $('<h1>').text(data[0]["name"]).appendTo('.result');
  //         console.log("success");
  //       },
  //       error: function(data) {
  //         console.log(data);
  //       }
  //       });
  //   }
// });
// });

