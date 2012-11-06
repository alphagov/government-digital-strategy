//nomensa
require(['modules/generate_player'], function(player) {
  $(player);
});


//bar charts
require(['modules/barcharts'], function(barCharts) {
  $(barCharts);
});

//set up sticky headings
require(['modules/stickyheaders'], function(setupStickyHeaders) {
  setupStickyHeaders();
});

// scrolling down and up
require(['modules/anchor_scrolling'], function(scrollToAnchor) {
  $("#markdown-toc a").on('click', function() {
    scrollToAnchor($(this).attr('href'));
  });
  $("#contents").on("click", function() {
    scrollToAnchor('html');
  });
});


