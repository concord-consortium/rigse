class CreateSaveableMultipleChoice < ActiveRecord::Migration
  def self.up
    create_table :saveable_multiple_choices do |t|
      t.integer     :learner_id
      t.integer     :multiple_choice_id
      t.timestamps
    end
    create_table :saveable_multiple_choice_answers do |t|
      t.integer     :multiple_choice_id
      t.integer     :bundle_content_id
      t.integer     :choice_id
      t.integer     :position
      t.timestamps
    end
    
  end

  def self.down
    drop_table :saveable_multiple_choice_answers
    drop_table :saveable_multiple_choices
  end
end
