# This migration comes from lightweight (originally 20120917190847)
class AddRelatedAndSidebarContent < ActiveRecord::Migration
  def up
    add_column :lightweight_lightweight_activities, :related, :text, :null => true
    add_column :lightweight_interactive_pages, :sidebar, :text, :null => true
  end

  def down
    remove_column :lightweight_lightweight_activities, :related
    remove_column :lightweight_interactive_pages, :sidebar
  end
end
