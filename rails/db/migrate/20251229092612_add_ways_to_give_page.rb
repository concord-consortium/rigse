class AddWaysToGivePage < ActiveRecord::Migration[8.0]
  def change
    add_column :admin_settings, :ways_to_give_page_content, :text, :limit => 16777215, :null => true
  end
end
