class BiologicaBreedOffspring < ActiveRecord::Base
  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  belongs_to :father_organism, :class_name => "BiologicaOrganism"
  belongs_to :mother_organism, :class_name => "BiologicaOrganism"
  
  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "Biologica Breed Offspring element"
  default_value_for :description, "description ..."
  default_value_for :width, 400
  default_value_for :height, 200
  
  def self.display_name
    "Biologica Breed Offspring"
  end


end
