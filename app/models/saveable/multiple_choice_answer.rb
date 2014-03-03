class Saveable::MultipleChoiceAnswer < ActiveRecord::Base
  self.table_name = "saveable_multiple_choice_answers"

  belongs_to :multiple_choice,  
    :class_name => 'Saveable::MultipleChoice', :counter_cache => :response_count,
    :inverse_of => :answers
  belongs_to :bundle_content, :class_name => 'Dataservice::BundleContent'
  
  has_many :rationale_choices, :order => :choice_id, :class_name => 'Saveable::MultipleChoiceRationaleChoice', :foreign_key => :answer_id, :dependent => :destroy

  acts_as_list :scope => :multiple_choice_id

  # unfortunately inverse_of isn't working in this case see https://github.com/rails/rails/pull/12359
  after_create do | saveable |
    saveable.multiple_choice.last_answer = saveable
    saveable.multiple_choice.save
  end

  after_destroy do | saveable |
    saveable.multiple_choice.update_last_answer
  end

  def answer
    if rationale_choices.size > 0
      rationale_choices.compact.select{|rc| rc.choice }.map{|rc| data = {:answer => rc.choice.choice, :correct => rc.choice.is_correct}; data[:rationale] = rc.rationale if rc.rationale; data }
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
