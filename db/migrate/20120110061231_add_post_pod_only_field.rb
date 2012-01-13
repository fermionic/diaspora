class AddPostPodOnlyField < ActiveRecord::Migration
  def self.up
    add_column :posts, :pod_only, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :posts, :pod_only
  end
end
