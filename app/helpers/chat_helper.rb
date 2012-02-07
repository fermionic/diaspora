module ChatHelper
  def initialize_chat_variables
    @chat_messages_unread = Hash.new { |h,k| h[k] = Array.new }
    @chat_partners = []  # To provide an ordering for display
    current_user.chat_messages_unread.order('id').each do |m|
      if ! @chat_partners.include?(m.author)
        @chat_partners << m.author
      end
      @chat_messages_unread[m.author] << m
    end

    @chat_messages_read = Hash.new { |h,k| h[k] = Array.new }
    @contact_persons_online = current_user.contacts_online.map(&:person)
    @contact_persons_online[0...6].each do |p|
      if ! @chat_partners.include?(p)
        @chat_partners << p
        @chat_messages_read[p] = ChatMessage.history_between(current_user.person, p, :limit => 5)
      end
    end
  end
end
