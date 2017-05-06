/* Set the width of the side navigation to 250px and the left margin of the page content to 250px */
function openNav() {
    $(".sidenav").css("width", "250px");
    $(".main").css("visibility", "hidden");
    $(".main").css("marginLeft", "250px");
    $(".main").css("visibility", "visible");
    $(".openbtn").hide();
}

/* Set the width of the side navigation to 0 and the left margin of the page content to 0 */
function closeNav() {
    $(".sidenav").css("width", "0");
    $(".main").css("visibility", "hidden");
    $(".main").css("marginLeft", "5%");
    $(".main").css("visibility", "visible");
    $(".openbtn").show(500);
}
function bind() {
    // Loading progress
    $("#load").show();
    // Search form wrapper
    var form = $("#search_form");

    var url = "/browse/search"; // search action
    var formData = form.serialize();

    $.get(url, formData, function(html) { // AJAX
      // Remove loading progress
      $("#load").hide();
      $("#search_result").html(html); // Replace the "results" div with the result
      setTimeout(arguments.callee, 1000);
      $(".clickable").click(function(){
        window.location.href = $(this).find("a").attr('href');
      });
    });
};

var searchWTimer = function(e){
  clearTimeout($.data(this, "timer"));
  if(e.keyCode == 13) {
  } else {
    $(this).data('timer',setTimeout(bind,500));
  }
}

var ready = function(){
  $("#search_bar_b").bind("keyup", searchWTimer);
  $(".check_box_b").change(searchWTimer);

  // row clicking.
  $(".clickables").click(function(){
    window.location.href = $(this).find("a").attr('href');
  });

  // Side bar menu
  $(".closebtn").click(closeNav);
  $(".openbtn").click(openNav);
  $("form").on("keypress", function (e) {
      if (e.keyCode == 13) {
          return false;
      }
  });
  $("#load").hide();
};
$(document).ready(ready);
$(document).on('turbolinks:load',ready);
