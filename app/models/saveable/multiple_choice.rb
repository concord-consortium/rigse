class Saveable::MultipleChoice < ActiveRecord::Base
  self.table_name = "saveable_multiple_choices"

  belongs_to :learner,        :class_name => 'Portal::Learner'
  belongs_to :offering,        :class_name => 'Portal::Offering'

  belongs_to :multiple_choice,  :class_name => 'Embeddable::MultipleChoice'

  has_many :answers, :dependent => :destroy , :order => :position, :class_name => "Saveable::MultipleChoiceAnswer"

  [ :prompt,
    :name,
    :choices,
    :has_correct_answer?,
    :has_duplicate_choices?
  ].each { |m| delegate m, :to => :multiple_choice, :class_name => 'Embeddable::MultipleChoice' }

  include Saveable::Saveable

  #
  # Override #answered? to ensure last answer was not the user
  # resetting the selection to the default un-selected state.
  #
  def answered?

    if answers.length == 0 
        return false
    end

    if  answers.last.answer                         &&
        answers.last.answer.length == 1             &&
        !(answers.last.answer[0].key?(:choice_id))

        #
        # The last answer is a list containing only one item, and it
        # does not contain a key for :choice_id. This is the answer we
        # generated in the case of unselecting a previous selection.
        # I.e. user is resetting to the default unselected state.
        # {:answer=>"not answered"}
        #

        return false
    end

    return true 
  end


  def embeddable
    multiple_choice
  end

  # TODO:  We shouldn't need to special case this. But we do.
  # We should use saveable.rb#answer, but because we are sending
  # an array of answers, it doesn't work.
  def answer
    if answered?
      answers.last.answer
    else
      [{:answer => "not answered"}]
    end
  end

  def submitted_answer
    if submitted?
      answers.last.answer
    elsif answered?
      [{:answer => "not submitted"}]
    else
      [{:answer => "not answered"}]
    end
  end

  def answered_correctly?
    if submitted?
      answers.last.answered_correctly?
    else
      false
    end
  end



end
