
$(function() {
  $(".horizontal-bar-chart").each(function(i, item) {
    var opts = {
      outOf: 70,
      autoOutdent: true
    }
    if($(item).hasClass("mc-stacked")) {
      opts.barPadding = 6;
    } else if(!$(item).hasClass("mc-negative")) {
      opts.barPadding = 6;
    }

    // some special cases
    $.magnaCharta($(item), opts);
  });
});

