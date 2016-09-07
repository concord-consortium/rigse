class Saveable::ImageQuestion < ActiveRecord::Base
  self.table_name = "saveable_image_questions"

  belongs_to :learner,        :class_name => 'Portal::Learner'
  belongs_to :offering,        :class_name => 'Portal::Offering'

  belongs_to :image_question,  :class_name => 'Embeddable::ImageQuestion'

  has_many :answers, :dependent => :destroy, :order => :position, :class_name => "Saveable::ImageQuestionAnswer"


  [:prompt, :name, :drawing_prompt].each { |m| delegate m, :to => :image_question, :class_name => 'Embeddable::ImageQuestion' }

  include Saveable::Saveable

  def embeddable
    image_question
  end

  def submitted_answer
    if submitted?
      answers.last.answer
    elsif answered?
      'not submitted'
    else
      'not answered'
    end
  end

  def add_external_answer(note, url, is_final = nil)
    blob = Dataservice::Blob.for_learner_and_url(self.learner, url)
    self.answers.create(:blob  => blob, :note => note, :is_final => is_final)
  end


end
