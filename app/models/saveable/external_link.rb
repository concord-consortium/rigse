class Saveable::ExternalLink < ActiveRecord::Base
  self.table_name = "saveable_external_links"

  belongs_to :learner,     :class_name => 'Portal::Learner'
  belongs_to :offering,    :class_name => 'Portal::Offering'

  belongs_to :embeddable,  :polymorphic => true

  has_many :answers, :dependent => :destroy ,:order => :position, :class_name => "Saveable::ExternalLinkUrl"

  delegate :name, :to => :embeddable

  # External link can be displayed in an iframe in teacher report.
  delegate :display_in_iframe, :to => :embeddable
  delegate :width, :to => :embeddable
  delegate :height, :to => :embeddable

  def answer
    if answered?
      answers.last.answer
    else
      'not answered'
    end
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

  def answered?
    answers.length > 0
  end

  def submitted?
    true
  end
end
