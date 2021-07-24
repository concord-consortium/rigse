class Saveable::OpenResponseAnswer < ApplicationRecord
  self.table_name = "saveable_open_response_answers"

  belongs_to :open_response,  :class_name => 'Saveable::OpenResponse', :counter_cache => :response_count

  acts_as_list :scope => :open_response_id
  delegate :learner, to: :open_response, allow_nil: :true
end
