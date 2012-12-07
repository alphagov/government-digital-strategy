
// Sticky Plugin
// =============
// Author: Anthony Garand
// Improvements by German M. Bravo (Kronuz) and Ruud Kamphuis (ruudk)
// Improvements by Leonardo C. Daronco (daronco)
// Created: 2/14/2011
// Date: 2/12/2012
// Website: http://labs.anthonygarand.com/sticky
// Description: Makes an element on the page stick on the screen as you scroll
//              It will only set the 'top' and 'position' of your element, you
//              might need to adjust the width in some cases.


// edits made by JF to bring it into RequireJS and some extra features
define(['modules/jquery.history'], function() {
  // dont refer to jQuery within the callback because this needs to attach to the global jQ
  (function($) {

    // if there is no hash, push a blank state
    var defaults = {
      topSpacing: 0,
      bottomSpacing: 0,
      className: 'is-sticky',
      wrapperClassName: 'sticky-wrapper'
    },
    $window = $(window),
    $document = $(document),
    sticked = [],
    windowHeight = $window.height(),
    scroller = function(event) {
      var scrollTop = $window.scrollTop(),
      documentHeight = $document.height(),
      dwh = documentHeight - windowHeight,
      extra = (scrollTop > dwh) ? dwh - scrollTop : 0;
      for (var i = 0; i < sticked.length; i++) {
        var s = sticked[i],
        elementTop = s.stickyWrapper.offset().top,
        etse = elementTop - s.topSpacing - extra;
        if (scrollTop <= etse) {
          if (s.currentTop !== null) {
            s.stickyElement
            .css('position', '')
            .css('top', '')
            .removeClass(s.className);
            s.stickyElement.parent().removeClass(s.className);
            // if(event.type == "scroll") {
            //   if(s.stickyElement.parents(".section").prev().find(".section-title").length > 0 && $(".is-sticky").length > 0) {
            //     window.History.replaceState({isPush: true}, document.title, ("#" + s.stickyElement.parents(".section").prev().find(".section-title").attr("id")))
            //   } else {
            //     // window.History.replaceState({isPush: true}, document.title, "#top");
            //     // this is really weird but seems to help fix the bug where sometimes it just wont update
            //     window.History.replaceState({isPush: true}, document.title, window.location.pathname + "");
            //   }
            // }
            s.currentTop = null;
          }
        }
        else {
          var newTop = documentHeight - s.stickyElement.outerHeight()
          - s.topSpacing - s.bottomSpacing - scrollTop - extra;
          if (newTop < 0) {
            newTop = newTop + s.topSpacing;
          } else {
            newTop = s.topSpacing;
          }
          if (s.currentTop != newTop) {
            s.stickyElement
            .css('position', 'fixed')
            .css('top', newTop)
            .addClass(s.className);
            s.stickyElement.parent().addClass(s.className);
            s.currentTop = newTop;

            // if(event.type == "scroll") {
            //   if(s.stickyElement.parents("h2").length > 0) {
            //     window.History.replaceState({isPush: true}, document.title, ("#" + s.stickyElement.parents("h2").attr("id")))
            //   }
            // }
          }
        }
      }
    },
    resizer = function() {
      windowHeight = $window.height();
    },
    methods = {
      init: function(options) {
        var o = $.extend(defaults, options);
        return this.each(function() {
          var stickyElement = $(this);

          stickyId = stickyElement.attr('id');
          wrapper = $('<div></div>')
          .attr('id', stickyId + '-sticky-wrapper')
          .addClass(o.wrapperClassName);
          stickyElement.wrapAll(wrapper);
          var stickyWrapper = stickyElement.parent();
          //stickyWrapper.css('height', stickyElement.outerHeight());
          sticked.push({
            topSpacing: o.topSpacing,
            bottomSpacing: o.bottomSpacing,
            stickyElement: stickyElement,
            currentTop: null,
            stickyWrapper: stickyWrapper,
            className: o.className
          });
        });
      },
      update: scroller
    };

    // should be more efficient than using $window.scroll(scroller) and $window.resize(resizer):
    // if (window.addEventListener) {
    //   window.addEventListener('scroll', scroller, false);
    //   window.addEventListener('resize', resizer, false);
    // } else if (window.attachEvent) {
    //   window.attachEvent('onscroll', scroller);
    //   window.attachEvent('onresize', resizer);
    // }
    $(window).on("scroll", scroller).on("resize", resizer);

    $.fn.sticky = function(method) {
      if (methods[method]) {
        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
      } else if (typeof method === 'object' || !method ) {
        return methods.init.apply( this, arguments );
      } else {
        $.error('Method ' + method + ' does not exist on jQuery.sticky');
      }
    };
    $(function() {
      setTimeout(scroller, 0);
    });
  })(jQuery);
});
