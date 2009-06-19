class BiologicaStaticOrganism < ActiveRecord::Base
  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  belongs_to :biologica_organism
  
  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "BiologicaStaticOrganism element"
  default_value_for :description, "description ..."

  def self.display_name
    "Biologicastaticorganism"
  end
  
  def organisms_in_activity_scope(scope)
    if scope && scope.class != BiologicaStaticOrganism
      scope.activity.biologica_organisms - [self]
    else
      []
    end
  end


end
