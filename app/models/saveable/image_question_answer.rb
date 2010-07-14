class Saveable::ImageQuestionAnswer < ActiveRecord::Base
  set_table_name "saveable_image_question_answers"

  belongs_to :image_question,  :class_name => 'Saveable::ImageQuestion', :counter_cache => :response_count
  belongs_to :bundle_content, :class_name => 'Dataservice::BundleContent'
  
  belongs_to :blob, :class_name => 'Dataservice::Blob'

  acts_as_list :scope => :image_question_id
  
  def answer
    if blob
      blob
    else
      "not answered"
    end
  end
end