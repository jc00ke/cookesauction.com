// Common JavaScript code across your application goes here.

$(document).ready(function() {
  $('#listing_photos a').fancybox();

  $("#listing_photos img").lazyload({
    effect: "fadeIn",
    placeHolder: "/fancybox/blank.gif"
   });

  $('#contact_us_accordian').accordion({
    collapsible: true,
    active: false,
    heightStyle: "content"
  });
});
