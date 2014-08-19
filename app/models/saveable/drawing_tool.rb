class Saveable::DrawingTool < ActiveRecord::Base
  set_table_name "saveable_drawing_tools"

  belongs_to :learner,        :class_name => 'Portal::Learner'
  belongs_to :offering,        :class_name => 'Portal::Offering'

  belongs_to :drawing_tool,  :class_name => 'Embeddable::DrawingTool'

  has_many :answers, :order => :position, :class_name => "Saveable::DrawingToolAnswer"

  def prompt
    nil
  end

  def name
    "Drawing Tool"
  end

  include Saveable::Saveable
  def answer
    if answered?
      answers.last.answer
    else
      "no drawing created"
    end
  end

  def answered?
    answers.length > 0
  end
end
