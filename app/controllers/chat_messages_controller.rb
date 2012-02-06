class ChatMessagesController < ApplicationController
  # include ApplicationHelper
  include ActionView::Helpers::SanitizeHelper
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :create

  def index

  end

  def create
    if current_user.id == 1
      recipient = User.find(2).person
    else
      recipient = User.find(1).person
    end

    if params['text'].nil?
      render :json => { 'success' => false }
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
