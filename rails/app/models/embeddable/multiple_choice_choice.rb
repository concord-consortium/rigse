class Embeddable::MultipleChoiceChoice < ActiveRecord::Base

  attr_accessible :choice, :multiple_choice_id, :is_correct, :external_id

  self.table_name = "embeddable_multiple_choice_choices"

  belongs_to :multiple_choice, :class_name => 'Embeddable::MultipleChoice'
end
