class Saveable::ImageQuestion < ActiveRecord::Base
  self.table_name = "saveable_image_questions"

  belongs_to :learner,        :class_name => 'Portal::Learner'
  belongs_to :offering,        :class_name => 'Portal::Offering'
  
  belongs_to :image_question,  :class_name => 'Embeddable::ImageQuestion'

  has_many :answers, :dependent => :destroy, :order => :position, :class_name => "Saveable::ImageQuestionAnswer"

  # has_one :answer, 
  #   :class_name => "Saveable::OpenResponseAnswer",
  #   :order => 'position DESC' 
  
  [:prompt, :name].each { |m| delegate m, :to => :image_question, :class_name => 'Embeddable::ImageQuestion' }
  
  include Saveable::Saveable
  
  def answer
    if answered?
      answers.last.answer
    else
      "not answered"
    end
  end
  
  def answered?
    answers.length > 0
  end

  def add_external_answer(note,url)
    blob = Dataservice::Blob.for_learner_and_url(self.learner, url)
    self.answers.create(:blob  => blob, :note => note)
  end
end
