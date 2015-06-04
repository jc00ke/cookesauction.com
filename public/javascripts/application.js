// Common JavaScript code across your application goes here.

$(document).ready(function() {
  $(".button-collapse").sideNav();
  $('.collapsible').collapsible();

  $('#listing_photos a').fancybox();

  $("#listing_photos img").lazyload({
    effect: "fadeIn",
    placeHolder: "/fancybox/blank.gif"
   });

});
