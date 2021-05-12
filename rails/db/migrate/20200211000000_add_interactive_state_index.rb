class AddInteractiveStateIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :saveable_interactive_states, [:interactive_id, :position], name: 'inter_id_and_position_index'
  end
end
