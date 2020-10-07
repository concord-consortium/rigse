class Saveable::InteractiveState < ActiveRecord::Base
  self.table_name = "saveable_interactive_states"

  attr_accessible :interactive_id, :bundle_content_id, :position, :state, :is_final, :feedback, :has_been_reviewed, :score

  belongs_to :interactive,  :class_name => 'Saveable::Interactive', :counter_cache => :response_count
  belongs_to :bundle_content, :class_name => 'Dataservice::BundleContent'

  acts_as_list :scope => :interactive_id

  delegate :learner, to: :interactive, allow_nil: :true

  def answer
    state
  end

  def answer=(ans)
    state = ans
  end
end
