class DefaultToPublic < ActiveRecord::Migration
  def self.up
    add_column :users, :default_to_public, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :default_to_public
  end
end
