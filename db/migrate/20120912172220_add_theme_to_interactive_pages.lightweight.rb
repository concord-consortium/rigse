# This migration comes from lightweight (originally 20120907150145)
class AddThemeToInteractivePages < ActiveRecord::Migration
  def change
    add_column :lightweight_interactive_pages, :theme, :string, :default => 'default'
  end
end
