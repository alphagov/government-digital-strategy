var ie = (function() {
  var undef,
  v = 3,
  div = document.createElement('div'),
  all = div.getElementsByTagName('i');
  do {
    div.innerHTML = '<!--[if gt IE ' + (++v) + ']><i></i><![endif]-->';
  } while(v < 10 && all[0]);

  return (v > 4) ? v : undef;
})();

// if it's IE6 or less, just stop here, and don't run any JS
if(ie && ie < 7) { return; }
//nomensa
require(['modules/generate_player'], function(player) {
  $(player);
});


$(function() {
  $("body").removeClass("no-js");
  $('.proportional.breakdown-chart tbody tr td:first-child').css('height', function(index) {
    return +($(this).text().replace('%', '')) * 4;
  });
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
    // some special cases
    $.magnaCharta($(item), {
      outOf: 70,
      autoOutdent: true,
    });
  });
});

// show toggle links
require(['modules/jquery.toggle'], function() {
  $(".show-hide").toggle({
    headingSelector: "p > a",
    contentSelector: ".show-hide-content"
  });
});


