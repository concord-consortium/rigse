class Saveable::ImageQuestionAnswer < ActiveRecord::Base
  self.table_name = "saveable_image_question_answers"

  attr_accessible :image_question_id, :bundle_content_id, :blob_id, :position, :note, :uuid, :is_final, :feedback, :has_been_reviewed, :score

  belongs_to :image_question,  :class_name => 'Saveable::ImageQuestion', :counter_cache => :response_count
  belongs_to :bundle_content, :class_name => 'Dataservice::BundleContent'

  belongs_to :blob, :class_name => 'Dataservice::Blob'

  acts_as_list :scope => :image_question_id
  delegate :learner, to: :image_question, allow_nil: :true

  def answer
    if blob || note
      {:blob => blob, :note => note}
    else
      "not answered"
    end
  end
end
