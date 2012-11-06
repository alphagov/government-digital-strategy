define(['jquery'], function() {
  var addText = function(item) {
    var $item = $(item);
    var index = $item.find(".title-index")
    var position = $item.find(".title-index .title-text")
    var newLink = $("<a />", {
      "href": "#"+item.id,
      "title": "Right click to copy a link to this section",
      "text": "[link to this section]",
      "class": "header-permalink"
    }).appendTo(position);
  }

  return {
    addText: addText
  }
});
