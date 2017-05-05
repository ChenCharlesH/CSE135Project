var bind = function() {
    // Loading progress
    $("#load").show();
    // Search form wrapper
    var form = $("#search_form");

    var url = "/products/search"; // search action
    var formData = form.serialize();

    $.get(url, formData, function(html) { // AJAX
      // Remove loading progress
      $("#load").hide();
      $("#search_result").html(html); // Replace the "results" div with the result
    });
};

var ready = function(){
  $("#search_bar").bind("keyup",bind);
  $(".check_box").change(bind);

  $("#load").hide();
  $("form").on("keypress", function (e) {
      if (e.keyCode == 13) {
          return false;
      }
  });
};
$(document).ready(ready);
$(document).on('turbolinks:load',ready);
