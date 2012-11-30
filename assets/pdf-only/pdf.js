
$(function() {
  $(".horizontal-bar-chart").each(function(i, item) {
    var opts = {
      outOf: 70,
      outdentAll: true
    }
    if(!$(item).hasClass("mc-negative")) {
      opts.barPadding = 6;
    }

    $.magnaCharta($(item), opts);
  });
});

