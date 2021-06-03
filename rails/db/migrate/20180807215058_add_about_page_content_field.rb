class AddAboutPageContentField < ActiveRecord::Migration
  def up
    add_column :admin_settings, :about_page_content, :text, :limit => 16777215, :null => true
  end

  def down
    remove_column :admin_settings, :about_page_content
  end
end
