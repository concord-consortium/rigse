class MultipleChoice < ActiveRecord::Base
  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  has_many :choices, :class_name => "MultipleChoiceChoice"
  
  accepts_nested_attributes_for :choices, :allow_destroy => true
  
  acts_as_replicatable

  include Changeable
  
  include TruncatableXhtml
  def before_save
    truncated_xhtml = truncate_from_xhtml(prompt)
    self.name = truncated_xhtml unless truncated_xhtml.empty?
  end

  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name description prompt}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "Multiple Choice Question element"
  default_value_for :description, "description ..."

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
