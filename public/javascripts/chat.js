$(document).ready( function() {
  $('#chat_badge').click( function() {
    $('#chat_dropdown').toggle();
    return false;
  } );

  $('#chat-text').keypress( function (e) {
    if( e.which == 13 ) {
      $(this).attr('disabled','disabled');
      $(this).addClass('disabled');
      $.post(
        '/chat_messages',
        { text: $(this).val() },
        function(data) {
          $('#chat-text').val('');
          $('#chat-text').removeClass('disabled');
          $('#chat-text').removeAttr('disabled');
        }
      );
    }
  } );
} );
