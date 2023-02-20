class Saveable::ImageQuestion < ApplicationRecord
  self.table_name = "saveable_image_questions"

  belongs_to :learner,        :class_name => 'Portal::Learner'
  belongs_to :offering,        :class_name => 'Portal::Offering'

  belongs_to :image_question,  :class_name => 'Embeddable::ImageQuestion'

  [:prompt, :name, :drawing_prompt].each { |m| delegate m, :to => :image_question }

  def embeddable
    image_question
  end
end
