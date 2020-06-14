class ChangeMultipleChoiceAnswers < ActiveRecord::Migration
  def self.up
    rename_table :multiple_choice_answers, :multiple_choice_choices
    rename_column :multiple_choice_choices, :answer, :choice
    change_column :multiple_choice_choices, :choice, :text
  end

  def self.down
    change_column :multiple_choice_choices, :choice, :string
    rename_column :multiple_choice_choices, :choice, :answer
    rename_table :multiple_choice_choices, :multiple_choice_answers
  end
end
