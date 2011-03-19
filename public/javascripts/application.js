// Common JavaScript code across your application goes here.

$(document).ready(function() {
  $('#listing_photos a').fancybox();

  $("a[href^='http']").not('rel="photos"').attr('target', '_blank');

  $("#listing_photos img").lazyload({
    effect: "fadeIn",
    placeHolder: "/fancybox/blank.gif"
   });
});
