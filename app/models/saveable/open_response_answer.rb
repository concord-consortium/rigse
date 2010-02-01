class Saveable::OpenResponseAnswer < ActiveRecord::Base
  set_table_name "saveable_open_response_answers"

  belongs_to :open_response,  :class_name => 'Saveable::OpenResponse'
  belongs_to :bundle_content, :class_name => 'Dataservice::BundleContent'

  acts_as_list :scope => :open_response_id
  
end
