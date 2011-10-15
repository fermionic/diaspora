#  Modified 10/14/2011 by Zach Prezkuta
#  Add User objects to various definitions to allow checking if the owner of posts, etc.
#  has chosen to "silence" his text from showing up in email notifications in the HAML
#  files that define the email text
#  Also add statements to scrub the subjects of emails that contain user text if user has
#  silenced his text

module NotificationMailers
  class AlsoCommented < NotificationMailers::Base
    include ActionView::Helpers::TextHelper

    attr_accessor :comment, :text_owner

    def set_headers(comment_id)
      @comment = Comment.find_by_id(comment_id)
      @text_owner = @comment.author.owner

      if mail?
        @headers[:from] = "\"#{@comment.author.name} (Diaspora*)\" <#{AppConfig[:smtp_sender_address]}>"
        @headers[:subject] = @text_owner.user_preferences.exists?(:email_type => 'silent') ? "#{t('notifier.comment_on_post.silenced_subject', :name => "#{@post_author_name}")}" : truncate(@comment.parent.comment_email_subject, :length => TRUNCATION_LEN)
        @headers[:subject] = "Re: #{@headers[:subject]}"
      end
    end

    def mail?
      @recipient && @sender && @comment
    end
  end
end
