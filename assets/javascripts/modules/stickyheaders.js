define(['modules/jquery.history', 'modules/jquery.sticky'], function() {
  return function() {
    // Duplicate section titles under section index
    $('h2.section-title .title-text').each(function(index) {
      var sectionIndex = $(this).parent().children('.title-index');
      $(this).clone().appendTo(sectionIndex);
    });

    // Make section indexes sticky
    $("#contents").sticky();
    $(".section-title .title-index").sticky({topSpacing:65});
  }
});
