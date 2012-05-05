#  Modified 5/4/2012 by Zach Prezkuta
#  Add User objects to various definitions to allow checking if the owner of posts, etc.
#  has chosen to "silence" his text from showing up in email notifications in the HAML
#  files that define the email text
#  Also add statements to scrub the subjects of emails that contain user text if user has
#  silenced his text

module NotificationMailers
  class Liked < NotificationMailers::Base
    attr_accessor :like, :text_owner

    def set_headers(like_id)
      @like = Like.find(like_id)
      @text_owner = @like.target.author.owner

      @headers[:subject] = I18n.t('notifier.liked.liked', :name => @sender.name)
    end
  end
end
