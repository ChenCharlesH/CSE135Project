function bind(form) {
    var url = "/analytics/query"; // search action
    var formData = form.serialize();

    $.ajax({
      type: "POST",
      url: url,
      data: formData,
      success: function(html) { // AJAX
        $("#query_result").html(html); // Replace the "results" div with the result
        ready()
    }
  });
};

// TODO: Add arrays to keep track of red, top 50, and purple for state changes.

var ready = function(){
  // Test purpling
  // $(".col1").fadeOut(1000).fadeIn(1000);
  // $(".col1").addClass("purple");
  // $(".col3").addClass("red");

  // Side bar menu
  $('.filter_options').submit(function(){
    bind($(this));
    return false;
  });
};
$(document).ready(ready);
$(document).on('turbolinks:load',ready);
