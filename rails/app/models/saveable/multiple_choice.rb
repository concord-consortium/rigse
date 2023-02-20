class Saveable::MultipleChoice < ApplicationRecord
  self.table_name = "saveable_multiple_choices"

  belongs_to :learner,        :class_name => 'Portal::Learner'
  belongs_to :offering,        :class_name => 'Portal::Offering'

  belongs_to :multiple_choice,  :class_name => 'Embeddable::MultipleChoice'

  [ :prompt,
    :name,
    :choices,
    :has_correct_answer?,
    :has_duplicate_choices?
  ].each { |m| delegate m, :to => :multiple_choice }

  def embeddable
    multiple_choice
  end
end
