#  Modified 5/4/2012 by Zach Prezkuta
#  Add User objects to various definitions to allow checking if the owner of posts, etc.
#  has chosen to "silence" his text from showing up in email notifications in the HAML
#  files that define the email text
#  Also add statements to scrub the subjects of emails that contain user text if user has
#  silenced his text

module NotificationMailers
  class Reshared < NotificationMailers::Base
    attr_accessor :reshare, :text_owner

    def set_headers(reshare_id)
      @reshare = Reshare.find(reshare_id)
      @text_owner = @reshare.root.author.owner

      @headers[:subject] = I18n.t('notifier.reshared.reshared', :name => @sender.name)
    end
  end
end
