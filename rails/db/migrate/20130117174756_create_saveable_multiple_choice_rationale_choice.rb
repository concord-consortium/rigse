class CreateSaveableMultipleChoiceRationaleChoice < ActiveRecord::Migration
  # This is a rich join model so that Saveable::MultipleChoice can support
  # multiple selection, and also support rationale.

  # faux models for successful migration
  class Saveable::MultipleChoiceAnswer < ActiveRecord::Base
    self.table_name = 'saveable_multiple_choice_answers'
  end

  class Saveable::MultipleChoiceRationaleChoice < ActiveRecord::Base
    self.table_name = 'saveable_multiple_choice_rationale_choices'
  end

  def up
    create_table :saveable_multiple_choice_rationale_choices do |t|
      t.integer :choice_id
      t.integer :answer_id
      t.string  :rationale

      t.timestamps
    end
    add_index :saveable_multiple_choice_rationale_choices, :choice_id
    add_index :saveable_multiple_choice_rationale_choices, :answer_id

    # Migrate the existing data over
    Saveable::MultipleChoiceAnswer.find_each do |answer|
      Saveable::MultipleChoiceRationaleChoice.create!(:choice_id => answer.choice_id, :answer_id => answer.id)
    end

    # Remove the old choice_id column on answers
    remove_column :saveable_multiple_choice_answers, :choice_id
  end

  def down
    # Add back the choice_id column on answers
    add_column :saveable_multiple_choice_answers, :choice_id, :integer

    # Migrate the existing data over
    Saveable::MultipleChoiceRationaleChoice.find_each do |r_choice|
      answer = Saveable::MultipleChoiceAnswer.find(r_choice.answer_id)
      answer.choice_id = r_choice.choice_id
      answer.save!
    end

    remove_index :saveable_multiple_choice_rationale_choices, :choice_id
    remove_index :saveable_multiple_choice_rationale_choices, :answer_id
    drop_table :saveable_multiple_choice_rationale_choices
  end
end
