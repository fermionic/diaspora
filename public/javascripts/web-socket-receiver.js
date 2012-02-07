var WSR = WebSocketReceiver = {
  initialize: function(url) {
    WSR.socket = new WebSocket(url);

    WSR.socket.onmessage = WSR.onMessage;
    WSR.socket.onopen = function() {
      WSR.socket.send(location.pathname);
    };
  },

  onMessage: function(evt) {
    var message = $.parseJSON(evt.data);

    if(message["class"].match(/^notifications/)) {
      Diaspora.page.header.notifications.showNotification(message);
    }
    else {
      switch(message["class"]) {
        case "retractions":
          ContentUpdater.removePostFromStream(message.post_id);
          break;
        case "comments":
          ContentUpdater.addCommentToPost(message.post_guid, message.comment_guid, message.html);
          break;
        case "likes":
          ContentUpdater.addLikesToPost(message.post_guid, message.html);
          break;
        case 'chat_messages':
          var convo = $('#chat_dropdown .incoming .conversation[data-person_id="' + message.author_id + '"]');
          convo
            .append(message.html)
            .scrollTop( $('#chat_dropdown .incoming')[0].scrollHeight )
          ;
          if( $('#chat_dropdown').css('display') == 'none' ) {
            var n = parseInt( $('#chat_badge .badge_count').html() );
            updateChatBadge( n+1 );
          } else if( ! convo.hasClass('active') ) {
            $.post( '/chat_messages_mark_all_as_read', { person_id: message.author_id } );
          }
        default:
          if(WSR.onPageForAspects(message.aspect_ids)) {
            ContentUpdater.addPostToStream(message.html);
          }
          break;
      }
    }
  },

  onPageForAspects: function(aspectIds) {
    var streamIds = $("#main_stream").attr("data-guids"),
        found = false;

    $.each(aspectIds, function(index, value) {
      if(WebSocketReceiver.onStreamForAspect(value, streamIds)) {
        found = true;
        return false;
      }
    });

    return found;
  },

  onStreamForAspect: function(aspectId, streamIds) {
    return (streamIds.search(aspectId) != -1);
  }
};
