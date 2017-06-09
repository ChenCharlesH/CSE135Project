function bind(form) {
    var url = "/analytics/refresh"; // search action
    $.ajax({
      type: "POST",
      url: url,
      data: {list_cols: JSON.stringify(list_cols)},
      success: function(html) { // AJAX
        $("#refresh_result").html(html); // Replace the "results" div with the result
        processData();
        updatePage();
        ready();
    }
  });
};

// Function to update page.
function updatePage(){
  // Clear all red and purple
  $(".red").removeClass("red");
  $(".purple").removeClass("purple");

  // Compare the column sums in ordered size.
  // Calculate new sum values.
  // Contains actual new sums.
  // |diff_column_sum| <= |col_sum_a|
  // Copy the col_sum_a
  new_sum_a = {}
  for(var key in col_sum_a){
    if(col_sum_a[key][0] == null)
      new_sum_a[key] = 0;
    else
      new_sum_a[key] = col_sum_a[key][0];
  }

  for(var key in diff_column_sum){
    val = 0
    if (diff_column_sum[key] != null){
      val = diff_column_sum[key];
    }

    if(key in new_sum_a)
      new_sum_a[key] = val + new_sum_a[key];
    else {
      new_sum_a[key] = val;
    }
  }

  sort_new_sum_a = sortMapByValue50(new_sum_a);
  text = ""
  for(var key in sort_new_sum_a) {
    if(key in col_sum_a){
      // Update the column with reds.
      updateColumn(key);
    }
    else{
      //<div id = "refresh_result">
      // Update text
      // get the name
      name = ""
      for(var i = 0; i < diff.length; ++i){
        if(diff[i]["product_id"].toString() == key.toString()){
          name = diff[i]["product_unique_name"]
        }
      }
        text += name + " is now in top 50." + " <br />";
    }
  }
  $("#text_result").html(text);


  // Set all purples
  for(var i = 0; i < 50; ++i){
    $('.col' + i.toString()).addClass("purple")
  }

  for(var key in col_sum_a){
    if(key in sort_new_sum_a)
      $('.col' + col_sum_a[key][1].toString()).removeClass("purple");
  }
};

function updateColumn(key){
  // Grab the column number
  col_num = col_sum_a[key][1]
  for(var i = 0; i < diff.length; ++i){
    // Get row number
    if(diff[i]["product_id"] == parseInt(key)){
      // Grab the state id.
      state = us_table[diff[i]["state"]];
      // Grab row id.
      row_num = row_sum_a[state.toString()][1];

      // Update the id to the correct value.
      id_val = "#" + row_num + col_num;
      elem =  $(id_val);

      // Get diff value.
      value = Number(0);
      if(diff[i]["total"] != null)
        value = Number(diff[i]["total"]);

      html_value = Number(elem.attr("value"));
      // Check if no change
      if(html_value == value + html_value)
        break;

      // Update the element!
      elem.html(Number(html_value + value));
      elem.addClass("red");
    }
  }

}

// Sort function from stack overflow
// @Ben Blank question: 5199901
function sortMapByValue50(map)
{
    var tupleArray = [];
    for (var key in map) tupleArray.push([key, map[key]]);
    tupleArray.sort(function (a, b) { return b[1] - a[1] });
    tupleArray = tupleArray.slice(0, 50);
    result = {};
    for (var i = 0; i < tupleArray.length; ++i) result[tupleArray[i][0]] = tupleArray[i][1];
    return result;
};


// Function to actually process and display data.
function processData(){
  if(typeof diff !== 'undefined')
    diff = jQuery.parseJSON(diff);

  if(typeof diff_column_sum !== 'undefined')
    diff_column_sum = jQuery.parseJSON(diff_column_sum);

  if(typeof diff_cols !== 'undefined')
    diff_cols = jQuery.parseJSON(diff_cols);
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

  if(typeof list_cols !== 'undefined')
    list_cols = jQuery.parseJSON(list_cols);

  // Side bar menu
  $('.refresh').click(function(){
    bind($(this));
    return false;
  });
};
$(document).ready(ready);
$(document).on('turbolinks:load',ready);
