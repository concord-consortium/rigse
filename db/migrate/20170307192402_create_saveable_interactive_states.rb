class CreateSaveableInteractiveStates < ActiveRecord::Migration
  def change
    create_table :saveable_interactive_states do |t|
      t.integer :interactive_id
      t.integer :bundle_content_id
      t.integer :position
      t.text    :state, :limit => 4294967295
      t.boolean :is_final
      t.text    :feedback
      t.boolean :has_been_reviewed, default: false
      t.integer :score

      t.timestamps
    end
  end
end
