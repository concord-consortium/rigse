class Saveable::MultipleChoiceAnswer < ActiveRecord::Base
  self.table_name = "saveable_multiple_choice_answers"

  belongs_to :multiple_choice,  :class_name => 'Saveable::MultipleChoice', :counter_cache => :response_count
  belongs_to :bundle_content, :class_name => 'Dataservice::BundleContent'

  has_many :rationale_choices, :order => :choice_id, :class_name => 'Saveable::MultipleChoiceRationaleChoice', :foreign_key => :answer_id, :dependent => :destroy

  acts_as_list :scope => :multiple_choice_id

  delegate :learner, to: :multiple_choice, allow_nil: :true
  def answer
    if rationale_choices.size > 0
      choices = multiple_choice.choices
      # figure out if we need to include indexes in the answer
      duplicate_choices = multiple_choice.has_duplicate_choices?

      rationale_choices.compact.select { |rc| rc.choice }.map do |rc|
        data = {
          :choice_id => rc.choice.id,
          :answer => rc.choice.choice,
          :correct => rc.choice.is_correct,
          :feedback => rc.answer.feedback
        }
        if duplicate_choices
          data[:answer] = "(#{choices.index(rc.choice) + 1})#{rc.choice.choice}"
        else
          data[:answer] = rc.choice.choice
        end
        data[:rationale] = rc.rationale if rc.rationale
        data
      end
    else
      [{:answer => "not answered"}]
    end
  end

  def submitted_answer
    if submitted? && answered?
      answer
    elsif answered?
      [{:answer => "not submitted"}]
    else
      [{:answer => "not answered"}]
    end
  end

  def answered_correctly?
    if rationale_choices.size > 0
      choices = rationale_choices.compact.select{|rc| rc.choice }.map{|rc| rc.choice.is_correct }
      !(choices.size == 0 || choices.include?(false))
    else
      false
    end
  end
end
