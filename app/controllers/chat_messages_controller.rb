class ChatMessagesController < ApplicationController
  # include ApplicationHelper
  include ActionView::Helpers::SanitizeHelper
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :create

  def index

  end

  def create
    if params['text'].nil? || params['partner'].nil?
      render :json => { 'success' => false }
      return
    end

    recipient = Person.find_by_diaspora_handle(params['partner'])
    if recipient.nil?
      if params['partner'].empty?
        message = 'Please specify the Diaspora ID of the person you wish to chat with.'
      end
      # Note that we don't want to reveal IDs to guessers,
      # so we don't say whether the ID is legit or not
      render :json => { 'success' => false, 'error' => message  }
      return
    elsif recipient == current_user.person
      render :json => { 'success' => false, 'error' => "Chesterton said that a man that does not talk to himself must not think he's someone worth talking to.  Good for you!" }
      return
    elsif ! recipient.owner.contacts.any? { |c| c.person == current_user.person && c.receiving }
      receiver_not_sharing = true
    end

    text = strip_tags( params['text'] )
    if ! text.empty?
      m = ChatMessage.create(
        :author => current_user.person,
        :recipient => recipient,
        :text => text[0...512]
      )
    end

    if m && m.valid?
      # We don't want to inform people whether other people are following them back,
      # so if the recipient is not following the sender, it's an uninformative failure.
      if ! receiver_not_sharing
        socketed = m.socket_to_user(recipient.owner)
        m.socket_to_user current_user
      end

      if socketed
        render :json => { 'success' => true }
      else
        render :json => { 'success' => false, 'error' => 'Your message could not be sent.  The recipient could be offline.' }
      end
    else
      render :json => { 'success' => false }
    end
  end
end
