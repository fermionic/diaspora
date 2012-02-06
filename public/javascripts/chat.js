$(document).ready( function() {
  $('#chat_badge').click( function() {
    $('#chat_dropdown').toggle();
    return false;
  } );

  $('#chat-text').keypress( function (e) {
    if( e.which == 13 ) {
      $.post(
        '/chat_messages',
        { text: $('#chat-text').val() },
        function(data) {
          $('#chat-text').val('');
        }
      );
    }
  } );
} );
