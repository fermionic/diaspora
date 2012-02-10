class AddChatWithAnyone < ActiveRecord::Migration
  def self.up
    add_column :users, :chat_with_anyone, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :users, :chat_with_anyone
  end
end
