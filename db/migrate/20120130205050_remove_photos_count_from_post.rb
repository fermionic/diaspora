class RemovePhotosCountFromPost < ActiveRecord::Migration
  def self.up
    # Not all DBs will have this, depending on when they started running Diaspora
    # Re: historical migrations, schemas, etc.
    if column_exists?( :posts, :photos_count )
      remove_column :posts, :photos_count
    end
  end

  def self.down
    # The column should never have been there.
  end
end
