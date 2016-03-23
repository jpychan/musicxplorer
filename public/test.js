$(function(){
$('form').on('submit', function() {
  console.log('Hey!');
  $.ajax({
    url: $("/search_flights").attr("action"),
    type: "POST",
    contentType: "text/javascript",
    beforeSend: function(xhr, settings) {
    xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
    }
  });
});

$('#click').on('click', function() {
  console.log('Hey!');
  // $.ajax({
  //   url: $("/search_flights").attr("action"),
  //   type: "POST",
  //   contentType: "text/javascript",
  //   beforeSend: function(xhr, settings) {
  //   xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
  //   }
  // });
  });
});
