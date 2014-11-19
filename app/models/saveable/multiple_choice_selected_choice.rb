class Saveable::MultipleChoiceSelectedChoice < ActiveRecord::Base
  self.table_name = "saveable_multiple_choice_selected_choices"

  belongs_to :answer, :class_name => "Saveable::MultipleChoiceAnswer"
  belongs_to :choice, :class_name => "Embeddable::MultipleChoiceChoice"
end
