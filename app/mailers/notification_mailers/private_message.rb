#  Modified 5/4/2012 by Zach Prezkuta
#  Add User objects to various definitions to allow checking if the owner of posts, etc.
#  has chosen to "silence" his text from showing up in email notifications in the HAML
#  files that define the email text
#  Also add statements to scrub the subjects of emails that contain user text if user has
#  silenced his text

module NotificationMailers
  class PrivateMessage < NotificationMailers::Base
    attr_accessor :message, :conversation, :participants, :text_owner

    def set_headers(message_id)
      @message  = Message.find_by_id(message_id)
      @conversation = @message.conversation
      @participants = @conversation.participants
      @text_owner = @message.author.owner

      @headers[:from] = "\"#{@message.author.name} (Diaspora*)\" <#{AppConfig[:smtp_sender_address]}>"
      @headers[:subject] = @text_owner.user_preferences.exists?(:email_type => 'silent') ? "#{I18n.t('notifier.private_message.silenced_subject', :name => "#{@sender.name}")}" : @conversation.subject.strip
      @headers[:subject] = "Re: #{@headers[:subject]}" if @conversation.messages.size > 1
    end
  end
end
