# This migration comes from lightweight (originally 20121011190609)
class AddWidthToMwInteractives < ActiveRecord::Migration
  def change
    add_column :lightweight_mw_interactives, :width, :float, :default => 60.0
  end
end
