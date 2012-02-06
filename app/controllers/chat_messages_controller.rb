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
      else
        message = "Unknown person: #{params['partner']}"
      end
      render :json => { 'success' => false, 'error' => message  }
      return
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
      m.socket_to_user recipient.owner
      m.socket_to_user current_user
      render :json => { 'success' => true }
    else
      render :json => { 'success' => false }
    end
  end
end
