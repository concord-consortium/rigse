class AddUuidToSaveableMultipleChoiceRationaleChoices < ActiveRecord::Migration
  def change
    add_column :saveable_multiple_choice_rationale_choices, :uuid, :string, :limit => 36
  end
end
