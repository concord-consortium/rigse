class CreateMultipleChoiceAnswers < ActiveRecord::Migration[5.1]
  def self.up
    create_table :multiple_choice_answers do |t|
      t.text :answer
      t.references :multiple_choice

      t.timestamps
    end
  end

  def self.down
    drop_table :multiple_choice_answers
  end
end
