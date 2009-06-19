class BiologicaOrganism < ActiveRecord::Base
  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  belongs_to :biologica_world
  
  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  @@available_sexes = { "male" => 0, "female" => 1, "random" => -1 }
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    def available_sexes
      @@available_sexes
    end
  end

  default_value_for :name, "Biologica Organism element"
  default_value_for :description, "description ..."

  def self.display_name
    "Biologica Organism"
  end


end
