var chat_dropdown_opened = false;

function updateChatBadge(n) {
  var badge = $('#chat_badge .badge_count');
  badge.html(n);
  if( n == 0 ) {
    badge.hide();
  } else {
    badge.show();
  }
}

function markActiveConversationRead() {
  $.post(
    '/chat_messages_mark_conversation_read',
    { person_id: $('.partner.active').data('person_id') },
    function(response) {
      updateChatBadge( parseInt(response.num_unread) );
    }
  );
}

function showChatMessages() {
  $('#chat_dropdown').show();
  if( ! chat_dropdown_opened ) {
    scrollToBottom( $('#chat_dropdown .conversation') );
    chat_dropdown_opened = true;
  }
  markActiveConversationRead();
}

function createChatConversation(person_id) {
  $.get(
    '/chat_messages_new_conversation.json',
    { person_id: person_id },
    function(response) {
      $('.partners').prepend( response.partner );
      $('.conversations').prepend( response.conversation );
      $('#chat-text').focus();
    }
  );
}

function scrollToBottom(jquery_set) {
  jquery_set[0].scrollTop = jquery_set[0].scrollHeight;
}

function addChatMessageToConversation( message, conversation ) {
  conversation.append(message.html);
  scrollToBottom(conversation);

  if( $('#chat_dropdown').css('display') == 'none' ) {
    var n = parseInt( $('#chat_badge .badge_count').html() );
    updateChatBadge( n+1 );
  } else if( conversation.hasClass('active') ) {
    markActiveConversationRead();
  }
}

function activateChatConversation( person_id ) {
  $('#chat_dropdown .conversation').hide();
  $('.partner, .conversation').removeClass('active');
  $('.partner[data-person_id="' + person_id + '"]').addClass('active');
  $('.conversation[data-person_id="' + person_id + '"]').addClass('active').show();
  markActiveConversationRead();
}

$(document).ready( function() {
  $('#chat_badge').click( function() {
    var dd = $('#chat_dropdown');
    if( dd.css('display') == 'none' ) {
      showChatMessages();
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
          partner: $('.partner.active').data('person_id')
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

  $('#people_stream.contacts .online .content').live( 'click', function() {
    showChatMessages();
    var person_id = $(this).data('person_id');
    if( $('.partners .partner[data-person_id="'+person_id+'"]').length ) {
      $('.partners .partner[data-person_id="'+person_id+'"]').click();
    } else {
      createChatConversation(person_id);
      activateChatConversation(person_id);
    }
  } );

  $('.chat_message')
    .live( 'mouseenter', function() { $(this).find('.to').show(); } )
    .live( 'mouseleave', function() { $(this).find('.to').hide(); } )
  ;

  $('.partner').live( 'click', function() {
    var person_id = $(this).data('person_id');
    activateChatConversation(person_id);
  } );
} );
