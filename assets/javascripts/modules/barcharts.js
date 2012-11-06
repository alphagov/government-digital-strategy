define([], function() {

  //TODO: this could do with some tidying and refactoring (JF)

  function isInt(value) {
    return !isNaN(parseInt(value)) && (parseFloat(value) == parseInt(value));
  }

  function isFloat(value) {
    return !isNaN(parseFloat(value));
  }
  var calculateMaxWidth = function(table) {

    table = $(table);
    var max_value = 0;
    var tableCells = table.find("td:odd");
    tableCells.each(function(index, item) {
      var $item = $(item),
          val = stripFromValue($item.text());

      //TODO: instead of this silly check, just use floats all the time (JF)
      if((isInt(val) && parseInt(val) > max_value) || (isFloat(val) && parseFloat(val) > max_value)) {
        max_value = parseFloat(val, 10)
      }
    });
    return {
      max: parseFloat(max_value, 10),
      single: (80/parseFloat(max_value, 10)) //this is 90 because we need the extra 10% for the label
    }

  };

  function stripFromValue(val) {
    return val.replace('%', '').replace("£", '').replace("m", "");
  }

  function calculateCellWidth(cell) {
    return parseFloat(stripFromValue($(cell).text()), 10)*max.single;
  }

  // Set heights of rows in a breakdown table based on their percentage share
  return function() {
    $('.proportional.breakdown-chart tbody tr td:first-child').css('height', function(index) {
      var height = +($(this).text().replace('%', '')) * 4;
      return height;
    });

    // Set heights of bars in a bar chart based on their value
    $('.bar-chart tbody tr td').css('height', function(index) {
      var height = +($(this).text().replace('%', '')) * 4;
      return height;
    });

    // Set width of bars in a bar chart based on their value
    //$('.horizontal-bar-chart tbody tr td').css('width', function(index) {
    //  var width = +($(this).text().replace('%', '')) * 4;
    //  return width;
    //});

    // Set width of bars in a bar chart based on their value
    var tables = $(".horizontal-bar-chart");
    tables.each(function(index, item) {
      max = calculateMaxWidth(item);
      var cells = $(item).find("td:odd");
      cells.each(function(index, cell) {
        var $cell = $(cell);
        var newWidth = calculateCellWidth(cell);
        $cell.css({
          "width": newWidth + "%",
          "text-indent" : (newWidth + 3) + "%",
          "text-align" : "none",
          "color" : "#111"
        });
      });
    });
    // $('.horizontal-bar-chart tbody tr td').css('width', function(index) {
    //   var width = +($(this).text().replace('%', '')) * 40;
    //   return width;
    // });
  };
});
