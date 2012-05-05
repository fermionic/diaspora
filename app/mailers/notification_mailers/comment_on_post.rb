#  Modified 5/4/2012 by Zach Prezkuta
#  Add User objects to various definitions to allow checking if the owner of posts, etc.
#  has chosen to "silence" his text from showing up in email notifications in the HAML
#  files that define the email text
#  Also add statements to scrub the subjects of emails that contain user text if user has
#  silenced his text

module NotificationMailers
  class CommentOnPost < NotificationMailers::Base
    include ActionView::Helpers::TextHelper

    attr_accessor :comment, :text_owner

    def set_headers(comment_id)
      @comment = Comment.find(comment_id)
      @text_owner = @comment.author.owner
      @post_owner = @comment.parent.author.owner
      @post_author_name = @comment.post.author.name

      @headers[:from] = "\"#{@comment.author.name} (Diaspora*)\" <#{AppConfig[:smtp_sender_address]}>"
      @headers[:subject] = @post_owner.user_preferences.exists?(:email_type => 'silent') ? "#{I18n.t('notifier.comment_on_post.silenced_subject', :name => "#{@post_author_name}")}" : truncate(@comment.parent.comment_email_subject, :length => TRUNCATION_LEN)
      @headers[:subject] = "Re: #{@headers[:subject]}"
    end
  end
end
