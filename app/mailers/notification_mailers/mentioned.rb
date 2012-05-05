#  Modified 5/4/2012 by Zach Prezkuta
#  Add User objects to various definitions to allow checking if the owner of posts, etc.
#  has chosen to "silence" his text from showing up in email notifications in the HAML
#  files that define the email text
#  Also add statements to scrub the subjects of emails that contain user text if user has
#  silenced his text

module NotificationMailers
  class Mentioned < NotificationMailers::Base
    attr_accessor :post, :text_owner

    def set_headers(target_id)
      @post = Mention.find_by_id(target_id).post
      @text_owner = @post.author.owner

      @headers[:subject] = I18n.t('notifier.mentioned.subject', :name => @sender.name)
    end
  end
end
