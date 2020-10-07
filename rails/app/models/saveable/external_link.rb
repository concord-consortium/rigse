class Saveable::ExternalLink < ActiveRecord::Base
  self.table_name = "saveable_external_links"

  attr_accessible :embeddable_id, :embeddable_type, :learner_id, :offering_id, :response_count

  belongs_to :learner,     :class_name => 'Portal::Learner'
  belongs_to :offering,    :class_name => 'Portal::Offering'

  belongs_to :embeddable,  :polymorphic => true

  has_many :answers, -> { order :position },
    dependent: :destroy,
    class_name: 'Saveable::ExternalLinkUrl'

  delegate :name, :to => :embeddable

  # External link can be displayed in an iframe in teacher report.
  delegate :display_in_iframe, :to => :embeddable
  delegate :width, :to => :embeddable
  delegate :height, :to => :embeddable

  include Saveable::Saveable

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
