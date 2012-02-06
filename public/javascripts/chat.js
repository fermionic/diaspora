function updateChatBadge(n) {
  var badge = $('#chat_badge .badge_count');
  badge.html(n);
  if( n == 0 ) {
    badge.hide();
  } else {
    badge.show();
  }
}

$(document).ready( function() {
  $('#chat_badge').click( function() {
    var dd = $('#chat_dropdown');
    if( dd.css('display') == 'none' ) {
      dd.show();
      updateChatBadge(0);
    } else {
      dd.hide();
    }
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
    updateChatBadge(0);
    $('#chat-partner').val( $(this).data('diaspora_handle') );
    $('#chat-text').focus();
  } );
} );
