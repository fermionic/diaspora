class CreateUserApiToken < ActiveRecord::Migration
  def self.up
    add_column :users, :token_api, :string, :limit => 32
    add_index :users, :token_api, :unique => true
  end

  def self.down
    remove_index :users, :token_api
    remove_column :users, :token_api
  end
end
