class CreateUserApiToken < ActiveRecord::Migration
  def self.up
    add_column :users, :api_token, :string, :limit => 32
    add_index :users, :api_token, :unique => true

    add_column :users, :api_time_last, :datetime
  end

  def self.down
    remove_column :users, :api_time_last

    remove_index :users, :api_token
    remove_column :users, :api_token
  end
end
