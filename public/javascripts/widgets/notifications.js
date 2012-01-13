
/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

(function() {
  var Notifications = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, notificationArea, badge) {
      $.extend(self, {
        badge: badge,
        count: parseInt(badge.html()) || 0,
        notificationArea: notificationArea
      });

      $(".unread-setter").live("mousedown", self.unreadClick);
      $(".stream_element.unread").live("mousedown", self.messageClick);
      $('.notification_element.read, .stream_element.read').live('mouseover', function() {
        $(this).find('.unread-setter').show();
      } );
      $('.notification_element.read, .stream_element.read').live('mouseout', function() {
        $(this).find('.unread-setter').hide();
      } );

      $("a.more").live("click", function(evt) {
        evt.preventDefault();
        $(this).hide()
          .next(".hidden")
          .removeClass("hidden");
      });
    });
    this.messageClick = function() {
      if( self.unreadClicked ) { return; }
      if( $(this).hasClass('read') ) { return; }
      $.ajax({
        url: "/notifications/" + $(this).data("guid"),
        data: { unread: 'false' },
        type: "PUT",
        success: self.clickSuccess
      });
    };
    this.unreadClick = function(evt) {
      self.unreadClicked = true;
      $.ajax({
        url: "/notifications/" + $(this).closest('.notification_element,.stream_element').data("guid"),
        data: { unread: 'true' },
        type: "PUT",
        success: self.clickSuccess
      });
    };
    this.clickSuccess = function( data ) {
      self.unreadClicked = false;
      var jsList = jQuery.parseJSON(data);
      var itemID = jsList["guid"]
      var isUnread = jsList["unread"]
      if ( isUnread ) {
        self.incrementCount();
      } else if( isUnread == false ) {
        self.decrementCount();
      }
      $('.read,.unread').each(function(index) {
        if ( $(this).data("guid") == itemID ) {
          if ( isUnread ) {
            $(this).removeClass("read").addClass( "unread" );
            $(this).find('.unread-setter').hide();
          } else {
            $(this).removeClass("unread").addClass( "read" );
          }
        }
      });
    };
    this.showNotification = function(notification) {
      $(notification.html).prependTo(this.notificationArea)
				.fadeIn(200)
				.delay(8000)
				.fadeOut(200, function() {
	  			$(this).detach();
				});

      if(typeof notification.incrementCount === "undefined" || notification.incrementCount) {
				this.incrementCount();
      }
    };

    this.changeNotificationCount = function(change) {
      self.count += change;

      if(self.badge.text() !== "") {
				self.badge.text(self.count);
        $( ".notification_count" ).text(self.count);

				if(self.count === 0) {
	  			self.badge.addClass("hidden");
          $( ".notification_count" ).removeClass("unread");
				}
				else if(self.count === 1) {
	  			self.badge.removeClass("hidden");
          $( ".notification_count" ).addClass("unread");
				}
      }
    };

    this.decrementCount = function() {
      self.changeNotificationCount(-1);
    };

    this.incrementCount = function() {
      self.changeNotificationCount(1);
    };
  };

  Diaspora.Widgets.Notifications = Notifications;
})();
