class AddLastAnswerToSaveableMultipleChoice < ActiveRecord::Migration
  class SaveableMultipleChoice < ActiveRecord::Base
  	has_many :answers, :order => :position, :class_name => "SaveableMultipleChoiceAnswer", :foreign_key => "multiple_choice_id"
  	belongs_to :last_answer, :class_name => "SaveableMultipleChoiceAnswer"
  end
  class SaveableMultipleChoiceAnswer < ActiveRecord::Base
  end

  def up
    add_column :saveable_multiple_choices, :last_answer_id, :integer
    SaveableMultipleChoice.find_each do | saveable |
      saveable.last_answer = saveable.answers.last
      saveable.save
    end
  end

  def down
  	remove_column :saveable_multiple_choices, :last_answer_id
  end
end
