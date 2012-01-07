(function() {
  var CommentStream = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, commentStream) {
      $.extend(self, {
        commentsList: commentStream.find("ul.comments"),
        commentToggler: commentStream.find(".toggle_post_comments"),
        moreCommentShower: commentStream.find('.show_more_comments'),
        comments: {}
      });

      self.commentsList.delegate(".new_comment", "ajax:failure", function() {
        Diaspora.Alert.show(Diaspora.I18n.t("failed_to_post_message"));
      });

      self.commentToggler.toggle(self.showComments, self.hideComments);
      self.moreCommentShower.click( self.showMoreComments );

      self.instantiateCommentWidgets();
    });

    this.instantiateCommentWidgets = function() {
      self.comments = {};

      self.commentsList.find("li.comment").each(function() {
        self.publish("comment/added", [$("#" + this.id)]);
      });
    };

    this.showComments = function(evt) {
      evt.preventDefault();

      if(self.commentsList.hasClass("loaded")) {
        self.commentToggler.html(Diaspora.I18n.t("comments.hide"));
        self.commentsList.removeClass("hidden");
      }
      else {
        $("<img/>", { alt: "loading", src: "/images/ajax-loader.gif"}).appendTo(self.commentToggler);

        $.get(self.commentToggler.attr("href"), function(data) {
          self.commentToggler.html(Diaspora.I18n.t("comments.hide"));
          self.moreCommentShower.remove();

          self.commentsList
            .html(data)
            .addClass("loaded")
            .removeClass("hidden");

          self.instantiateCommentWidgets();
        });
      }
    };

    this.showMoreComments = function(evt) {
      evt.preventDefault();

      var shower = self.moreCommentShower;

      $("<img/>", { alt: "loading", src: "/images/ajax-loader.gif"}).appendTo(shower);

      $.get(shower.attr("href") + '?num=' + shower.data('num'), function(data) {
        var shower_ = self.moreCommentShower;
        shower.find('img').remove();

        var num_left = parseInt($('<div>'+data+'</div>').find('.num_left').text());
        if( num_left > 0 ) {
          var num_more = 6;
          if( num_left < 6 ) {
            num_more = num_left;
          }
          shower_.find('.num_more').html(num_more);
          shower_.data('num', parseInt(shower_.data('num')) + num_more );
        } else {
          shower_.remove();
          self.commentToggler.html(Diaspora.I18n.t("comments.hide"));
          self.commentsList.addClass("loaded");
        }

        self.commentsList
          .html(data)
          .removeClass("hidden")
        ;

        self.instantiateCommentWidgets();
      });
    };

    this.hideComments = function(evt) {
      evt.preventDefault();

      self.commentToggler.html(Diaspora.I18n.t("comments.show"));
      self.commentsList.addClass("hidden");
    };

    this.subscribe("comment/added", function(evt, comment) {
      self.comments[comment.attr("id")] = self.instantiate("Comment", comment);
    });
  };

  Diaspora.Widgets.CommentStream = CommentStream;
})();
