class Saveable::Interactive < ActiveRecord::Base
  self.table_name = "saveable_interactives"

  attr_accessible :learner_id, :offering_id, :response_count, :iframe_id

  belongs_to :learner,     :class_name => 'Portal::Learner'
  belongs_to :offering,    :class_name => 'Portal::Offering'

  belongs_to :iframe,  :class_name => 'Embeddable::Iframe'

  has_many :answers, -> { order :position },
    :dependent => :destroy,
    :class_name => "Saveable::InteractiveState"

  delegate :name, :to => :iframe

  # Interactive can be displayed in an iframe in teacher report.
  delegate :display_in_iframe, :to => :iframe
  delegate :width, :to => :iframe
  delegate :height, :to => :iframe

  include Saveable::Saveable

  def embeddable
    iframe
  end

  def submitted_answer
    if submitted?
      answers.last.answer
    elsif answered?
      'not submitted'
    else
      'not answered'
    end
  end

  def submitted?
    true
  end
end
