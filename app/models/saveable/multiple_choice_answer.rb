class Saveable::MultipleChoiceAnswer < ActiveRecord::Base
  set_table_name "saveable_multiple_choice_answers"

  belongs_to :multiple_choice,  :class_name => 'Saveable::MultipleChoice', :counter_cache => :response_count
  belongs_to :bundle_content, :class_name => 'Dataservice::BundleContent'
  
  has_many :selected_choices, :order => :choice_id, :class_name => 'Saveable::MultipleChoiceSelectedChoice', :foreign_key => :answer_id, :dependent => :destroy

  acts_as_list :scope => :multiple_choice_id
  
  def answer
    if selected_choices.size > 0
      selected_choices.compact.select{|sc| sc.choice }.map{|sc| {:choice_id => sc.choice.id, :answer => sc.choice.choice, :correct => sc.choice.is_correct} }
    else
      [{:answer => "not answered", :choice_id => 0}]
    end
  end
  
  def answered_correctly?
    if selected_choices.size > 0
      choices = selected_choices.compact.select{|sc| sc.choice }.map{|sc| sc.choice.is_correct}
      !(choices.size == 0 || choices.include?(false))
    else
      false
    end
  end
end
