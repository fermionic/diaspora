class CreateTagExclusions < ActiveRecord::Migration

  def self.up
    create_table :tag_exclusions do |t|
      t.integer :user_id, :null => false
      t.integer :tag_id, :null => false
      t.timestamps
    end

    add_index :tag_exclusions, :tag_id
    add_index :tag_exclusions, :user_id
    add_index :tag_exclusions, [:tag_id, :user_id], :unique => true
  end

  def self.down
    remove_index :tag_exclusions, :column => [:tag_id, :user_id]
    remove_index :tag_exclusions, :column => :user_id
    remove_index :tag_exclusions, :column => :tag_id

    drop_table :tag_exclusions
  end

end
