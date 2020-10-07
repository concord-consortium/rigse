class Saveable::OpenResponse < ActiveRecord::Base
  self.table_name = "saveable_open_responses"

  attr_accessible :learner_id, :open_response_id, :offering_id, :response_count

  belongs_to :learner,        :class_name => 'Portal::Learner'
  belongs_to :offering,        :class_name => 'Portal::Offering'

  belongs_to :open_response,  :class_name => 'Embeddable::OpenResponse'

  has_many :answers, -> { order :position },
    :dependent => :destroy,
    :class_name => "Saveable::OpenResponseAnswer"


  [:prompt, :name].each { |m| delegate m, :to => :open_response, :class_name => 'Embeddable::OpenResponse' }

  include Saveable::Saveable

  #
  # Override answered? to ensure last answer is not empty.
  #
  def answered?
    answers.length > 0 && answers.last.answer && answers.last.answer.present?
  end

  def embeddable
    open_response
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


end
