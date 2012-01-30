class RemovePhotosCountFromPost < ActiveRecord::Migration
  def self.up
    remove_column :posts, :photos_count
  end

  def self.down
    add_column :posts, :photos_count, :integer, :default => 0
    execute %{
      UPDATE posts
      SET photos_count = (
        SELECT COUNT(*)
        FROM photos
        WHERE photos.status_message_guid = posts.guid
      )
    }
  end
end
