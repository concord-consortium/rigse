# This migration comes from lightweight (originally 20120914133227)
class AddOfferingsCounts < ActiveRecord::Migration
  def up
    add_column :lightweight_lightweight_activities, :offerings_count, :integer
    add_column :lightweight_interactive_pages, :offerings_count, :integer
  end

  def down
    remove_column :lightweight_lightweight_activities, :offerings_count
    remove_column :lightweight_interactive_pages, :offerings_count
  end
end
