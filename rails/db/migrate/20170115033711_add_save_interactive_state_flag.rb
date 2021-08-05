class AddSaveInteractiveStateFlag < ActiveRecord::Migration[5.1]
  def change
    add_column :interactives, :save_interactive_state, :boolean, :default => false
  end
end
