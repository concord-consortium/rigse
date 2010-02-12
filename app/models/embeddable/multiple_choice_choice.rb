class Embeddable::MultipleChoiceChoice < ActiveRecord::Base
  set_table_name "embeddable_multiple_choice_choices"

  belongs_to :multiple_choice, :class_name => 'Embeddable::MultipleChoice'
end
