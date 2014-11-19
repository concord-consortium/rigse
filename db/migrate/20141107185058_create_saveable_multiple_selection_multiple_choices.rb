class CreateSaveableMultipleSelectionMultipleChoices < ActiveRecord::Migration
  # This is a rich join model so that Saveable::MultipleChoice can support
  # multiple selection.

  # faux models for successful migration
  class Saveable::MultipleChoiceAnswer < ActiveRecord::Base
    self.table_name = 'saveable_multiple_choice_answers'
  end

  class Saveable::MultipleChoiceSelectedChoice < ActiveRecord::Base
    self.table_name = 'saveable_multiple_choice_selected_choices'
  end

  def self.up
    create_table :saveable_multiple_choice_selected_choices do |t|
      t.integer :choice_id
      t.integer :answer_id

      t.timestamps
    end
    add_index :saveable_multiple_choice_selected_choices, :choice_id
    add_index :saveable_multiple_choice_selected_choices, :answer_id

    # Migrate the existing data over
    Saveable::MultipleChoiceAnswer.find_each do |answer|
      Saveable::MultipleChoiceSelectedChoice.create!(:choice_id => answer.choice_id, :answer_id => answer.id)
    end

    # Remove the old choice_id column on answers
    remove_column :saveable_multiple_choice_answers, :choice_id
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
