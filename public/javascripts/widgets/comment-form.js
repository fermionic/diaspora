(function() {
  var CommentForm = function() {
    var self = this;


    this.subscribe("widget/ready", function(evt, commentFormElement) {
      $.extend(self, {
        commentFormElement: commentFormElement,
        commentInput: commentFormElement.find("textarea"),
        initRan:false
      });

      self.commentInput.autoResize();
      self.commentInput.focus(self.showCommentForm);
      if (!self.initRan) {
        self.initPreviewAjax();
        self.initRan = true;
      }
    });

    this.initPreviewAjax = function() {
      self.commentFormElement.find('#comm-preview:not(.dim)').live( 'click', function(evt) {
        evt.preventDefault();
        $( this ).addClass('dim');

        $.post('/comment_preview.json', { text: self.commentFormElement.find('.comment_box[name=text]').val() },
          function(data){
            self.showPreviewItems(self.commentFormElement, data);
          }
        );
        return false;
      });
      self.commentFormElement.find('#comm-preview-edit.comment-preview:not(.dim)').live( 'click', function(evt) {
        evt.preventDefault();
        self.hidePreviewItems(self.commentFormElement);
        return false;
      });
    }
    this.formSubmissionComplete = function(formElement) {
      this.hidePreviewItems(formElement);
    }
    this.showPreviewItems = function(formElement, data) {
      formElement.find('#comm-preview').hide();
      formElement.find( '#comm-preview-edit').removeClass("dim").show();
      formElement.find( '#comment_form').hide();
      var commPreview = formElement.find("#comment_preview")
      commPreview.show();
      commPreview.find(".comment.previews").html(data.result);
      commPreview.find("abbr.timeago").timeago();
    }
    this.hidePreviewItems = function(formElement) {
      formElement.find( '#comm-preview').removeClass("dim").show();
      formElement.find( '#comment_form').show();
      formElement.find( '#comment_preview').hide();
      formElement.find( '#comm-preview-edit').hide();
    }
    this.showCommentForm = function() {
      self.commentFormElement.parent().removeClass("hidden");
      self.commentFormElement.addClass("open");
    };
  };

  Diaspora.Widgets.CommentForm = CommentForm;
})();
