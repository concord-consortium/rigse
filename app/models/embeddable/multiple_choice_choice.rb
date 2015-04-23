class Embeddable::MultipleChoiceChoice < ActiveRecord::Base
  set_table_name "embeddable_multiple_choice_choices"

  belongs_to :multiple_choice, :class_name => 'Embeddable::MultipleChoice'

  def export_as_lara_activity
    {
      :choice => self.choice,
      :is_correct => self.is_correct,
      :prompt => ""
    }
  end
end
