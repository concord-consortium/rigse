class Saveable::OpenResponseAnswer < ActiveRecord::Base
  self.table_name = "saveable_open_response_answers"

  belongs_to :open_response,  :class_name => 'Saveable::OpenResponse', :counter_cache => :response_count
  belongs_to :bundle_content, :class_name => 'Dataservice::BundleContent'

  acts_as_list :scope => :open_response_id
  
end
