define([], function() {
  // Visibly scroll to an anchor tag
  return function(aid) {
    $('html,body').animate({scrollTop: $(aid).offset().top - 63 },50);
  };
});
