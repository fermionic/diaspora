function updateNumUnread() {
  $.getJSON(
    '/notifications/num_unread.json',
    function(data) {
      var num_unread = parseInt(data.num_unread);
      $('#notification_badge .badge_count').html(num_unread);
      if( num_unread == 0 ) {
        $('#notification_badge .badge_count').addClass('hidden');
      } else {
        $('#notification_badge .badge_count').removeClass('hidden');
      }
    }
  );
}

(function() {
  var Header = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, header) {
      self.notifications = self.instantiate("Notifications",
        header.find("#notifications"),
        header.find("#notification_badge .badge_count")
      );

      self.notificationsDropdown = self.instantiate("NotificationsDropdown",
        header.find("#notification_badge"),
        header.find("#notification_dropdown")
      );

      self.search = self.instantiate("Search", header.find(".search_form"));
      self.menuElement = self.instantiate("UserDropdown", header.find("#user_menu"));
    });
  };

  Diaspora.Widgets.Header = Header;

  $(document).ready( function() {
    setTimeout( 'updateNumUnread();', 3000 );
  } );
})();
