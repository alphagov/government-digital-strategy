//nomensa
require(['modules/generate_player'], function(player) {
  $(player);
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

require(['modules/magna-charta.min'], function() {
  $(".horizontal-bar-chart").each(function(i, item) {
    var opts = {
      outOf: 70,
      autoOutdent: true
    }
    if($(item).hasClass("mc-stacked")) {
      opts.barPadding = 5;
    } else if(!$(item).hasClass("mc-negative")) {
      opts.barPadding = 2;
    }

    // some special cases
    $.magnaCharta($(item), opts);
  });
  $('.proportional.breakdown-chart tbody tr td:first-child').css('height', function(index) {
    var height = +($(this).text().replace('%', '')) * 4;
    return height;
  });
});


