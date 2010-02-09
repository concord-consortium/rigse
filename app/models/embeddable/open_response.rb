class Embeddable::OpenResponse < ActiveRecord::Base
  set_table_name "embeddable_open_responses"

  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity

  has_many :saveables, :class_name => "Saveable::OpenResponse", :foreign_key => :open_response_id do
    def by_offering(offering)
      find(:all, :conditions => { :offering_id => offering.id })
    end
  end

  acts_as_replicatable

  include Changeable
  include TruncatableXhtml
  # Including TruncatableXhtml adds a before_save hook which will automatically
  # generate a name attribute for the model instance if there is any content on 
  # the main xhtml attribute (examples: content or prompt) that can plausibly be 
  # turned into a name. Otherwise the default_value_for :name specified below is used.

  self.extend SearchableModel
  
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

  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end

end
