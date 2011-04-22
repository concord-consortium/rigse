class Embeddable::OpenResponse < Embeddable::Embeddable
  set_table_name "embeddable_open_responses"


  has_many :saveables, :class_name => "Saveable::OpenResponse", :foreign_key => :open_response_id do
    def by_offering(offering)
      find(:all, :conditions => { :offering_id => offering.id })
    end
    def by_learner(learner)
      find(:all, :conditions => { :learner_id => learner.id })
    end
    def first_by_learner(learner)
      find(:first, :conditions => { :learner_id => learner.id })
    end
  end
  include TruncatableXhtml
  # Including TruncatableXhtml adds a before_save hook which will automatically
  # generate a name attribute for the model instance if there is any content on 
  # the main xhtml attribute (examples: content or prompt) that can plausibly be 
  # turned into a name. Otherwise the default_value_for :name specified below is used.
  
  @@searchable_attributes = %w{uuid name description prompt}

  class <<self
   def searchable_attributes
     @@searchable_attributes
   end
  end

  default_value_for :name, "Open Response Question"
  default_value_for :description, "What is the purpose of this question ...?"
  default_value_for :prompt, <<-HEREDOC
  <p>You can use HTML content to <b>write</b> the prompt of the question ...</p>
  HEREDOC
  # as per RITES-260 "Open response text field should be empty"
  default_value_for :default_response, "" 
  
  send_update_events_to :investigations
  
  def self.display_name
    "Open Response"
  end

end
