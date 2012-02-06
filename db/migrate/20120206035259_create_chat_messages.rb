class CreateChatMessages < ActiveRecord::Migration
  def self.up
    create_table :chat_messages do |t|
      t.string :text, :limit => 512
      t.integer :author_id
      t.integer :recipient_id
      t.timestamps
    end
  end

  def self.down
    drop_table :chat_messages
  end
end
