class Saveable::InteractiveState < ApplicationRecord
  self.table_name = "saveable_interactive_states"

  belongs_to :interactive,  :class_name => 'Saveable::Interactive', :counter_cache => :response_count

  acts_as_list :scope => :interactive_id

  delegate :learner, to: :interactive, allow_nil: :true

  def answer
    state
  end

  def answer=(ans)
    state = ans
  end
end
