class AddAboutPageContentField < ActiveRecord::Migration
  def up
    add_column :admin_settings, :about_page_content, :mediumtext, :default => "", :null => true
  end

  def down
    remove_column :admin_settings, :about_page_content
  end
end
