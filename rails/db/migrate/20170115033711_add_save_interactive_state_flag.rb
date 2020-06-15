class AddSaveInteractiveStateFlag < ActiveRecord::Migration
  def change
    add_column :interactives, :save_interactive_state, :boolean, :default => false
  end
end
