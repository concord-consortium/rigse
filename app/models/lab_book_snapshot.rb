class LabBookSnapshot < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :target_element, :polymorphic => true
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "LabBookSnapshot element"
  default_value_for :description, "description ..."

  def self.display_name
    "Snapshot Button"
  end

  def other_elements_on_page
    results = []
    pages.each do |p|
      results << p.page_elements.map { |elem| elem.embeddable }
    end
    results.flatten!
    results - [self]
  end

  def targeted_id
    if target_element
      return LabBookSnapshot.encode(target_element)
    end
    return "none"
  end
  
  def targeted_id=(string)
    self.target_element = LabBookSnapshot.decode(string)
  end
  
  def self.encode(element)
    return "#{element.class.name.underscore}_#{element.id}"
  end
  
  def self.decode(string)
    m = string.match /(.*)_(\d+)/
    if m && m.size == 3
      klass = m[1].classify.constantize
      elem_id = m[2].to_i
      puts klass
      found = klass.find(elem_id)
      puts "==================================== found: #{found}"
      return klass.find(elem_id)
    end
    return nil
  end
  

end
