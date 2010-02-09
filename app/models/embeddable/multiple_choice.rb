class Embeddable::MultipleChoice < ActiveRecord::Base
  set_table_name "embeddable_multiple_choices"

  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  has_many :choices, :class_name => "Embeddable::MultipleChoiceChoice", :dependent => :destroy
  
  has_many :saveables, :class_name => "Saveable::MultipleChoice", :foreign_key => :multiple_choice_id do
    def by_offering(offering)
      find(:all, :conditions => { :offering_id => offering.id })
    end
  end
  
  accepts_nested_attributes_for :choices, :allow_destroy => true
  
  acts_as_replicatable

  include Changeable
  include TruncatableXhtml
  # Including TruncatableXhtml adds a before_save hook which will automatically
  # generate a name attribute for the model instance if there is any content on 
  # the main xhtml attribute (examples: content or prompt) that can plausibly be 
  # turned into a name. Otherwise the default_value_for :name specified below is used.

  include Cloneable
  self.extend SearchableModel
    
  @@cloneable_associations = [:choices]
  @@searchable_attributes = %w{uuid name description prompt}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    def cloneable_associations
      @@cloneable_associations
    end
  end

  default_value_for :name, "Multiple Choice Question element"
  default_value_for :description, "description ..."
  default_value_for :prompt, "Why do you think ..."
  default_value_for :choices, [
    Embeddable::MultipleChoiceChoice.new(:choice => 'a'),
    Embeddable::MultipleChoiceChoice.new(:choice => 'b'),
    Embeddable::MultipleChoiceChoice.new(:choice => 'c')
  ]
  send_update_events_to :investigations

  def self.display_name
    "Multiple Choice Question"
  end

  def to_xml(options ={})
    options[:incude] = :choices
    super(options)
  end

  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end

end
