function bind(form) {
    var url = "/analytics/query"; // search action
    var formData = form.serialize();

    $.ajax({
      type: "POST",
      url: url,
      data: formData,
      success: function(html) { // AJAX
        $("#refresh_result").html(html); // Replace the "results" div with the result
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
  // alert(jQuery.parseJSON(us_table)[3].id);

  // Convert data to readable data.
  if(typeof us_table !== 'undefined')
    us_table = jQuery.parseJSON(us_table);

  if(typeof col_sum_a !== 'undefined')
    col_sum_a = jQuery.parseJSON(col_sum_a);

  if(typeof row_sum_a !== 'undefined')
    row_sum_a = jQuery.parseJSON(row_sum_a);

  // Side bar menu
  $('.filter_options').submit(function(){
    bind($(this));
    return false;
  });
};
$(document).ready(ready);
$(document).on('turbolinks:load',ready);
