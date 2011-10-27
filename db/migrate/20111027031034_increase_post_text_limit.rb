class IncreasePostTextLimit < ActiveRecord::Migration
  def self.up
    change_column :posts, :text, :text, :limit => 500000
  end

  def self.down
    change_column :posts, :text, :text, :limit => nil
  end
end
