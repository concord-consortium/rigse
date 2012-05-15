class Saveable::MultipleChoice < ActiveRecord::Base
  self.table_name = "saveable_multiple_choices"

  belongs_to :learner,        :class_name => 'Portal::Learner'
  belongs_to :offering,        :class_name => 'Portal::Offering'

  belongs_to :multiple_choice,  :class_name => 'Embeddable::MultipleChoice'

  has_many :answers, :order => :position, :class_name => "Saveable::MultipleChoiceAnswer"
  
  [:prompt, :name, :choices].each { |m| delegate m, :to => :multiple_choice, :class_name => 'Embeddable::MultipleChoice' }

  include Saveable::Saveable

  def answer
    if answered?
      answers.last.answer
    else
      "not answered"
    end
  end
  
  def answered?
    answers.length > 0
  end
  
  def answered_correctly?
    if answered?
      answers.last.answered_correctly?
    else
      false
    end
  end
end
