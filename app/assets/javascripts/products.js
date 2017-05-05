$(document).ready(function(){
  $("#search_bar").bind("keyup", function() {

    // Loading progress
    $("#search_bar").addClass("loading");
    // Search form wrapper
    var form = $("#search_form");

    var url = "/products/search"; // search action
    var formData = form.serialize();

    $.get(url, formData, function(html) { // AJAX
      // Remove loading progress
      $("#search_bar").removeClass("loading");
      $("#search_result").html(html); // Replace the "results" div with the result
    });
  });

  $("form").on("keypress", function (e) {
      if (e.keyCode == 13) {
          return false;
      }
  });
});
