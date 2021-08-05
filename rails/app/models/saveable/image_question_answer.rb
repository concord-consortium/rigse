class Saveable::ImageQuestionAnswer < ApplicationRecord
  self.table_name = "saveable_image_question_answers"

  belongs_to :image_question,  :class_name => 'Saveable::ImageQuestion', :counter_cache => :response_count
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
