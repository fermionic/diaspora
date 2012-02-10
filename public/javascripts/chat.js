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

function updateConversationBadge( person_id, n ) {
  var badge = $('.partner[data-person_id="' + person_id + '"] .badge_count');
  badge.html(n);
  if( n == 0 ) {
    badge.hide();
  } else {
    badge.show();
  }
}

function markActiveConversationRead() {
  var person_id = $('.partner.active').data('person_id');
  $.post(
    '/chat_messages_mark_conversation_read',
    { person_id: person_id },
    function(response) {
      updateChatBadge( parseInt(response.num_unread) );
      updateConversationBadge(person_id, 0)
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

function setCurrentChatNameAndStatusFromActive() {
  var text = $('.partner.active').data('person_name');
  var status = $('.partner.active').data('contact_status');
  if( status ) {
    text = text + ' (' + status + ')';
  }
  $('.partner-current').html(text);
}

function createChatConversation(person_id) {
  $.get(
    '/chat_messages_new_conversation.json',
    { person_id: person_id },
    function(response) {
      $('.partners').prepend( response.partner );
      $('.conversations').prepend( response.conversation );
      scrollToBottom( $('#chat_dropdown .conversation') );
      setCurrentChatNameAndStatusFromActive();
      $('#chat-text').focus();
    }
  );
}

function scrollToBottom(jquery_set) {
  var obj = jquery_set[0];
  if( obj ) {
    obj.scrollTop = obj.scrollHeight;
  }
}

function addChatMessageToConversation( message, conversation ) {
  conversation.append(message.html);
  scrollToBottom(conversation);

  if( $('#chat_dropdown').css('display') == 'none' ) {
    var n = parseInt( $('#chat_badge .badge_count').html() );
    updateChatBadge( n+1 );
  } else if( conversation.hasClass('active') ) {
    markActiveConversationRead();
    $('.partner[data-person_id="' + message.person_id + '"]').data('contact_status', message.contact_status);
    setCurrentChatNameAndStatusFromActive();
  } else {
    var n = parseInt( $('.partner[data-person_id="' + message.person_id + '"] .badge_count').html() );
    updateConversationBadge(message.person_id, n+1)
    $('.partner[data-person_id="' + message.person_id + '"]').data('contact_status', message.contact_status);
  }
}

function activateChatConversation( person_id ) {
  $('#chat_dropdown .conversation').hide();
  $('.partner, .conversation').removeClass('active');
  $('.partner[data-person_id="' + person_id + '"]').addClass('active');
  $('.conversation[data-person_id="' + person_id + '"]').addClass('active').show();
  setCurrentChatNameAndStatusFromActive();
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

  $('a.chat').live( 'click', function() {
    showChatMessages();
    var person_id = $(this).data('person_id');
    if( $('.partners .partner[data-person_id="'+person_id+'"]').length ) {
      $('.partners .partner[data-person_id="'+person_id+'"]').click();
    } else {
      createChatConversation(person_id);
      activateChatConversation(person_id);
    }
    return false;
  } );

  $('#people_stream.contacts .content')
    .live( 'mouseenter', function() { $(this).find('.chat_links').show(); } )
    .live( 'mouseleave', function() { $(this).find('.chat_links').hide(); } )
  ;

  $('.chat_message')
    .live( 'mouseenter', function() { $(this).find('.to').show(); } )
    .live( 'mouseleave', function() { $(this).find('.to').hide(); } )
  ;

  $('.partner').live( 'click', function() {
    var person_id = $(this).data('person_id');
    activateChatConversation(person_id);
  } );

  $('#chat_status').change( function() {
    var status_new = $(this).find('option:selected').val();
    $.get('/update_chat_status/?chat_status=' + status_new);
  } );
} );
