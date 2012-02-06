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

    m = ChatMessage.create!(
      :author => current_user.person,
      :recipient => recipient,
      :text => strip_tags( params['text'] )
    )
    m.socket_to_user recipient.owner
    render :json => { 'success' => '1' }
  end
end
