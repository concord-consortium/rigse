class AddExternalIdToOpenResponseAndMultipleChoice < ActiveRecord::Migration
  def change
    add_column :embeddable_open_responses, :external_id, :string
    add_column :embeddable_multiple_choices, :external_id, :string
    add_column :embeddable_multiple_choice_choices, :external_id, :string
  end
end
