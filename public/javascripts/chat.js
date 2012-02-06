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
        {
          text: $(this).val(),
          partner: $('#chat-partner').val()
        },
        function(data) {
          if( ! data.success ) {
            if( data.error ) {
              alert(data.error);
            }
          } else {
            $('#chat-text').val('');
          }

          $('#chat-text').removeClass('disabled');
          $('#chat-text').removeAttr('disabled');
        }
      );
    }
  } );

  $('#people_stream.contacts .online .content').click( function() {
    $('#chat_dropdown').show();
    $('#chat-partner').val( $(this).data('diaspora_handle') );
    $('#chat-text').focus();
  } );
} );
