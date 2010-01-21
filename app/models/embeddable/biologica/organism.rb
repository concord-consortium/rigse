class Embeddable::Biologica::Organism < ActiveRecord::Base
  set_table_name "embeddable_biologica_organisms"

  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  belongs_to :biologica_world, :class_name => 'Embeddable::Biologica::World'
  
  has_many :biologica_static_organisms, :class_name => 'Embeddable::Biologica::StaticOrganism'
  has_many :biologica_chromosomes, :class_name => 'Embeddable::Biologica::Chromosome'
  
  has_and_belongs_to_many :biologica_chromosome_zooms, :class_name => 'Embeddable::Biologica::ChromosomeZoom'
  has_and_belongs_to_many :biologica_multiple_organisms, :class_name => 'Embeddable::Biologica::MultipleOrganism'
  has_and_belongs_to_many :biologica_pedigrees, :class_name => 'Embeddable::Biologica::Pedigree'
  
  send_update_events_to :investigations

#  has_many :biologica_meiosis_views, :class_name => 'Embeddable::Biologica::MeiosisView'
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
  
#  has_many :biologica_breed_offsprings, :class_name => 'Embeddable::Biologica::BreedOffspring'
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
  
  include Cloneable
  @@cloneable_associations = [:biologica_world]

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
    def cloneable_associations
      @@cloneable_associations
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
  
  def self.by_scope(scope)
    if scope && scope.class != Embeddable::Biologica::Organism
      scope.activity.investigation.organisms
    else
      []
    end
  end

  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end

end
