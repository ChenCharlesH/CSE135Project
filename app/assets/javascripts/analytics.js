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

var ready = function(){
  // Side bar menu
  $('.filter_options').submit(function(){
    bind($(this));
    return false;
  });
};
$(document).ready(ready);
$(document).on('turbolinks:load',ready);
