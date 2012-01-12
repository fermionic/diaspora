/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

(function() {
  var InfiniteScroll = function() {
    var self = this;
    this.options = {
      bufferPx: 40,
      debug: false,
      donetext: Diaspora.I18n.t("infinite_scroll.no_more"),
      loadingText: "",
      loadingImg: "/images/ajax-loader.gif",
      navSelector: "#pagination",
      nextSelector: ".paginate",
      itemSelector: ".stream_element",
      pathParse: function(pathStr) {
        var newPath = pathStr.replace("?", "?only_posts=true&"),
        	lastTime = $('#main_stream .stream_element').last().find(".time").attr("integer");

        if(lastTime === undefined){
        	lastTime = $('#main_stream').data('time_for_scroll');
        }

        return newPath.replace(/max_time=\d+/, "max_time=" + lastTime);
      }
    };
    this.initializing = true;

    this.subscribe("widget/ready", function() {
      if($('#main_stream').length !== 0) {
        $('#main_stream').infinitescroll(self.options, function(newElements) {
          self.globalPublish("stream/scrolled", newElements);
          /* If stream page size is configured to be a small number, the initial page
          load may not have enough posts to generate the vertical scrollbar.  Without
          the scrollbar, the user cannot trigger infinitescroll, so we must force more
          posts in. */
          if( $(document).height() <= $(window).height() ) {
            $('#main_stream').infinitescroll('retrieve');
          }
        });
      } else if($('#people_stream').length !== 0) {
        $("#people_stream").infinitescroll($.extend(self.options, {
          navSelector  : ".pagination",
          nextSelector : ".next_page",
          pathParse : function(pathStr, nextPage) {
            return pathStr.replace("page=2", "page=" + nextPage);
          }
        }), function(newElements) {
          self.globalPublish("stream/scrolled", newElements);
        });
      }
    });

    this.reInitialize = function() {
      $("#main_stream").infinitescroll("destroy");
      self.publish("widget/ready");
    };

    this.globalSubscribe("stream/reloaded", self.reInitialize, this);
  };

  Diaspora.Widgets.InfiniteScroll = InfiniteScroll;
})();

