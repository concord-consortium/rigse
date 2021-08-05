class AddIsFinalToSaveableMultipleChoiceAnswers < ActiveRecord::Migration[5.1]
  def change
    add_column :saveable_multiple_choice_answers, :is_final, :boolean
  end
end
