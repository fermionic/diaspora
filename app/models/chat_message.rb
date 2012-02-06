class ChatMessage < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include ROXML
  include Diaspora::Webhooks
  # include Diaspora::Relayable
  include Diaspora::Socketable

  belongs_to :author, :class_name => 'Person'
  belongs_to :recipient, :class_name => 'Person'

  def socket_to_user(user_or_id, opts={})
    user_id = user_or_id.instance_of?(Fixnum) ? user_or_id : user_or_id.id
    super(user_or_id, opts)
  end

end
