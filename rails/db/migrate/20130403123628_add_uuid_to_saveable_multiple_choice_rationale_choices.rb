class AddUuidToSaveableMultipleChoiceRationaleChoices < ActiveRecord::Migration[5.1]
  def change
    add_column :saveable_multiple_choice_rationale_choices, :uuid, :string, :limit => 36
  end
end
