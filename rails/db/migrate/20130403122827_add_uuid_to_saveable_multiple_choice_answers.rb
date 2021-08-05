class AddUuidToSaveableMultipleChoiceAnswers < ActiveRecord::Migration[5.1]
  def change
    add_column :saveable_multiple_choice_answers, :uuid, :string, :limit => 36
  end
end
