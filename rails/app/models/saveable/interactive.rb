class Saveable::Interactive < ApplicationRecord
  self.table_name = "saveable_interactives"

  belongs_to :learner,     :class_name => 'Portal::Learner'
  belongs_to :offering,    :class_name => 'Portal::Offering'

  belongs_to :iframe,  :class_name => 'Embeddable::Iframe'

  delegate :name, :to => :iframe

  # Interactive can be displayed in an iframe in teacher report.
  delegate :display_in_iframe, :to => :iframe
  delegate :width, :to => :iframe
  delegate :height, :to => :iframe

  def embeddable
    iframe
  end
end
