$(document).ready(function(){
  $("#load").hide();
  $("#search_bar").bind("keyup", function() {

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
  });

  $("form").on("keypress", function (e) {
      if (e.keyCode == 13) {
          return false;
      }
  });
});
