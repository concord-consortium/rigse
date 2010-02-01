class Saveable::OpenResponse < ActiveRecord::Base
  set_table_name "saveable_open_responses"

  belongs_to :learner,        :class_name => 'Portal::Learner'
  belongs_to :open_response,  :class_name => 'Embeddable::OpenResponse'

  has_many :answers, :order => :position, :class_name => "Saveable::OpenResponseAnswer"

  # has_one :answer, 
  #   :class_name => "Saveable::OpenResponseAnswer",
  #   :order => 'position DESC' 
  
  delegate :prompt, :to => :open_response, :class_name => 'Embeddable::OpenResponse'
  
  def answer
    self.answers.last.answer
  end
end
