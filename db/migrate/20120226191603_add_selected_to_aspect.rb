class AddSelectedToAspect < ActiveRecord::Migration
  def self.up
    add_column :aspects, :selected, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :aspects, :selected
  end
end
