class BiologicaOrganism < ActiveRecord::Base
  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  belongs_to :biologica_world
  
  has_many :biologica_static_organisms
  has_many :biologica_chromosomes
#  has_many :biologica_chroomosome_zooms

  has_and_belongs_to_many :biologica_multiple_organisms
  has_and_belongs_to_many :biologica_pedigrees
  
#  has_many :biologica_meiosis_views
# Can we model this via normal rails associations?
# It can be associated via either BiologicaMeiosisView.father_organism_id or BiologicaMeiosisView.mother_organism_id
  def biologica_meiosis_views
    if self.sex == 0  # MALE
      return BiologicaMeiosisView.find(:all, :conditions => {:father_organism_id => self.id})
    elsif self.sex == 1
      return BiologicaMeiosisView.find(:all, :conditions => {:mother_organism_id => self.id})
    end
    return []
  end
  
#  has_many :biologica_breed_offsprings
# the same goes for the breed offspring views.
def biologica_breed_offsprings
  if self.sex == 0  # MALE
    return BiologicaBreedOffspring.find(:all, :conditions => {:father_organism_id => self.id})
  elsif self.sex == 1
    return BiologicaBreedOffspring.find(:all, :conditions => {:mother_organism_id => self.id})
  end
  return []
end
  
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
  default_value_for :sex, -1
  default_value_for :fatal_characteristics, true

  def self.display_name
    "Biologica Organism"
  end
  
  
  def self.male
    0
  end
  
  def self.female
    1
  end

end
