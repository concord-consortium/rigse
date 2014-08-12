class Saveable::DrawingToolAnswer < ActiveRecord::Base
  set_table_name "saveable_drawing_tool_answers"

  belongs_to :drawing_tool,  :class_name => 'Saveable::DrawingTool', :counter_cache => :response_count
  belongs_to :bundle_content, :class_name => 'Dataservice::BundleContent'

  acts_as_list :scope => :drawing_tool_id

end
