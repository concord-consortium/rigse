class MultipleChoice < ActiveRecord::Base
  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  has_many :choices, :class_name => "MultipleChoiceChoice"
  
  accepts_nested_attributes_for :choices, :allow_destroy => true
  
  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name description prompt}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "Multiple Choice Question element"
  default_value_for :description, "description ..."

  def self.display_name
    "Multiple Choice Question"
  end

  def to_xml(options ={})
    options[:incude] = :choices
    super(options)
  end

end
