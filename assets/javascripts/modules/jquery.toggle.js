// plugin for toggling
define([], function() {
  (function($) {
    $.fn.toggle = function(opts) {
      var defaults = {
        headingSelector: ".toggle-header",
        contentSelector: ".toggle-content"
      };
      var settings = $.extend({}, defaults, opts);
      return this.each(function() {
        var wrapper = $(this);
        var toggle = wrapper.find(settings.headingSelector).show();
        var content = wrapper.find(settings.contentSelector).hide();
        toggle.on("click", function(e) {
          console.log("clicked");
          console.log(content);
          e.preventDefault();
          content.toggle();
        });
      });
    }
  })(jQuery);
});
