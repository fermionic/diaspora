module ChatHelper
  def initialize_chat_variables
    @chat_messages_unread = Hash.new { |h,k| h[k] = Array.new }
    @chat_partners = []  # To provide an ordering for display
    @chat_statuses = Hash.new( I18n.t('chat.status.offline') )

    current_user.chat_messages_unread.order('id').each do |m|
      if ! @chat_partners.include?(m.author)
        @chat_partners << m.author
      end
      @chat_messages_unread[m.author] << m
    end

    @chat_messages_read = Hash.new { |h,k| h[k] = Array.new }
    current_user.contacts_online[0...6].each do |c|
      if ! @chat_partners.include?(c.person)
        @chat_partners << c.person
        @chat_messages_read[c.person] = ChatMessage.history_between(current_user.person, c.person, :limit => 5)
        @chat_statuses[c.person] = c.chat_status_display
      end
    end
  end
end
