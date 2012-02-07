class ChatMessagesController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include MarkdownifyHelper
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :create

  def create
    if params['text'].nil? || params['partner'].nil?
      render :json => { 'success' => false }
      return
    end

    recipient = Person.find(params['partner'].to_i)
    if recipient.nil?
      # Note that we don't want to reveal IDs to guessers,
      # so we don't say whether the ID is legit or not
      render :json => { 'success' => false, 'error' => 'Invalid chat partner.' }
      return
    elsif recipient == current_user.person
      render :json => { 'success' => false, 'error' => "Chesterton said that a man that does not talk to himself must not think he's someone worth talking to.  Good for you!" }
      return
    elsif (
      ! recipient.owner.chat_with_anyone &&
      ! recipient.owner.contacts.any? { |c| c.person == current_user.person && c.receiving }
    )
      receiver_wont_receive = true
    end

    text = strip_tags( params['text'] )
    if ! text.empty?
      if text.length > 512
        render :json => { 'success' => false, 'error' => 'Messages cannot be longer than 512 characters.' }
        return
      end

      # We don't want to inform people whether other people are following them back,
      # so if the recipient is not following the sender, it's an uninformative failure.
      if ! receiver_wont_receive
        m = ChatMessage.create(
          :author => current_user.person,
          :recipient => recipient,
          :text => text
        )
      end
    end

    if m && m.valid?
      if m.socket_to_user(recipient.owner)
        m.socket_to_user current_user
        render :json => { 'success' => true }
      else
        render :json => {
          'success' => false,
          'error' => "#{recipient.name} may be offline.  Messages sent to offline contacts are saved for them to read later."
        }
      end
    else
      render :json => { 'success' => false }
    end
  end

  def mark_conversation_read
    author_id = params['person_id'].to_i
    ActiveRecord::Base.connection.execute %{
      UPDATE chat_messages
      SET read = true
      WHERE
        recipient_id = #{current_user.person.id}
        AND author_id = #{author_id}
    }
    render :json => { 'num_unread' => current_user.chat_messages_unread.size }
  end

  def new_conversation
    partner = Person.find( params['person_id'].to_i )
    if partner
      render :json => {
        'partner' => render_to_string( :partial => 'chat_messages/partner.html.erb', :locals => { :partner => partner, :first => true } ),
        'conversation' => render_to_string( :partial => 'chat_messages/conversation.html.erb', :locals => { :partner => partner, :first => true, :messages => [] } )
      }
    else
      render :json => { 'partner' => '', 'conversation' => '' }
    end
  end
end
