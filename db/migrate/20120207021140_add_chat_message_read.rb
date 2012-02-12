class AddChatMessageRead < ActiveRecord::Migration
  def self.up
    add_column :chat_messages, :read, :boolean, :default => false, :null => false
    if postgres?
      execute 'UPDATE chat_messages SET read = true'
    else # MySQL
      execute 'UPDATE chat_messages SET `read` = true'
    end
  end

  def self.down
    remove_column :chat_messages, :read
  end
end
