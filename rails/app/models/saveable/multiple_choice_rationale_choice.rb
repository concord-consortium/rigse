class Saveable::MultipleChoiceRationaleChoice < ActiveRecord::Base
  self.table_name = "saveable_multiple_choice_rationale_choices"

  attr_accessible :choice_id, :answer_id, :rationale, :uuid

  belongs_to :answer, :class_name => "Saveable::MultipleChoiceAnswer"
  belongs_to :choice, :class_name => "Embeddable::MultipleChoiceChoice"
end

