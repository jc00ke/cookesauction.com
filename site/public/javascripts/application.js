// Common JavaScript code across your application goes here.

var destroyDialog = function() { $('#dialog').dialog('destroy'); };

$(document).ready(function() {
  
  $('#email_signup a').click(function(e) {
    e.preventDefault();
    $('#dialog').dialog({
      title: 'Email List',
      autoOpen: true,
      width: 330,
      height: 300,
      draggable: false,
      modal: true,
      resizable: false,
      open: function() {
        $('#dialog').load('/signup form');
      },
      close: function() {
        destroyDialog();
      },
      buttons: {
        'Signup': function() {
          $.ajax({
            type: "POST",
            url: "/signup",
            data: { name: $('#name').val(), your_email: $('#your_email').val() },
            success: function(thanks){
              $('#dialog').html(thanks);
              setTimeout(function() { destroyDialog() }, 1500 );
            },
            error: function(oops) {
              $('#dialog').html(oops);
            }
          });
        },
        'Cancel': function() {
          destroyDialog();
        }
      }
    });
  });
  
});
