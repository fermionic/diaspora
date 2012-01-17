class AddCustomCssAndJavascript < ActiveRecord::Migration
  def self.up
    add_column :users, :custom_css, :text
    add_column :users, :custom_js, :text
  end

  def self.down
    remove_column :users, :custom_js
    remove_column :users, :custom_css
  end
end
