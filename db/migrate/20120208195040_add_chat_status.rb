class AddChatStatus < ActiveRecord::Migration
  def self.up
    add_column :users, :chat_status, :string, :null => false, :default => 'offline'
  end

  def self.down
    remove_column :users, :chat_status
  end
end
