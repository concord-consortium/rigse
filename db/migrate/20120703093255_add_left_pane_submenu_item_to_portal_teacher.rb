class AddLeftPaneSubmenuItemToPortalTeacher < ActiveRecord::Migration
  def self.up
    add_column :portal_teachers, :left_pane_submenu_item, :integer
  end

  def self.down
    remove_column :portal_teachers, :left_pane_submenu_item
  end
end
