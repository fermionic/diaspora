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

  def self.history_between(p1, p2, options = {})
    limit = options[:limit] || 5
    read = options[:read].nil? ? true : options[:read]
    if postgres?
      read_column = 'read'
    else # MySQL
      read_column = '`read`'
    end
    where(
      %{
        (
          recipient_id = ? AND author_id = ?
          OR recipient_id = ? AND author_id = ?
        )
        AND #{read_column} = ?
      },
      p1.id, p2.id,
      p2.id, p1.id,
      read
    ).order('id DESC').limit(limit).reverse
  end

end
