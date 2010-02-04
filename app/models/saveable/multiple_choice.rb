class Saveable::MultipleChoice < ActiveRecord::Base
  set_table_name "saveable_multiple_choices"

  belongs_to :learner,        :class_name => 'Portal::Learner'
  belongs_to :multiple_choice,  :class_name => 'Embeddable::MultipleChoice'

  has_many :answers, :order => :position, :class_name => "Saveable::MultipleChoiceAnswer"
  
  [:prompt, :name].each { |m| delegate m, :to => :multiple_choice, :class_name => 'Embeddable::MultipleChoice' }
  
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
end
