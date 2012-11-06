define(['modules/jqueryui.min', 'modules/swfobject', 'modules/jquery.player.min'], function() {
  return function() {
    // Find all links to videos on youtube
    var $yt_links = $("figure a[href*='http://www.youtube.com/watch']");
    // Create players for our youtube links
    $.each($yt_links, function(i) {
      var $holder = $('<span />');
      $(this).parent().replaceWith($holder);
      // Find the captions file if it exists
      var $mycaptions = $(this).siblings('.captions');
      // Work out if we have captions or not
      var captionsf = $($mycaptions).length > 0 ? $($mycaptions).attr('href') : null;
      // Ensure that we extract the last part of the youtube link (the video id)
      // and pass it to the player() method
      var link = $(this).attr('href').split("=")[1];
      // Initialise the player
      $holder.player({
        id:'yt'+i,
        media:link,
        captions:captionsf
      });
    });
  };
});
