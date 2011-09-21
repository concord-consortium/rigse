class Embeddable::Biologica::Organism < ActiveRecord::Base
  set_table_name "embeddable_biologica_organisms"

  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  belongs_to :world, :class_name => 'Embeddable::Biologica::World'
  
  has_many :static_organisms, :class_name => 'Embeddable::Biologica::StaticOrganism'
  has_many :chromosomes, :class_name => 'Embeddable::Biologica::Chromosome'
  
  has_and_belongs_to_many :chromosome_zooms, :class_name => 'Embeddable::Biologica::ChromosomeZoom', :join_table => 'embeddable_biologica_chromosome_zooms_organisms'
  has_and_belongs_to_many :multiple_organisms, :class_name => 'Embeddable::Biologica::MultipleOrganism', :join_table => 'embeddable_biologica_multiple_organisms_organisms'
  has_and_belongs_to_many :pedigrees, :class_name => 'Embeddable::Biologica::Pedigree', :join_table => 'embeddable_biologica_organisms_pedigrees'
  
  send_update_events_to :investigations

#  has_many :meiosis_views, :class_name => 'Embeddable::Biologica::MeiosisView'
# Can we model this via normal rails associations?
# It can be associated via either BiologicaMeiosisView.father_organism_id or BiologicaMeiosisView.mother_organism_id
  def meiosis_views
    if self.sex == 0  # MALE
      return Embeddable::Biologica::MeiosisView.find(:all, :conditions => {:father_organism_id => self.id})
    elsif self.sex == 1
      return Embeddable::Biologica::MeiosisView.find(:all, :conditions => {:mother_organism_id => self.id})
    end
    return []
  end
  
#  has_many :breed_offsprings, :class_name => 'Embeddable::Biologica::BreedOffspring'
# the same goes for the breed offspring views.
def breed_offsprings
  if self.sex == 0  # MALE
    return Embeddable::Biologica::BreedOffspring.find(:all, :conditions => {:father_organism_id => self.id})
  elsif self.sex == 1
    return Embeddable::Biologica::BreedOffspring.find(:all, :conditions => {:mother_organism_id => self.id})
  end
  return []
end
  
  acts_as_replicatable

  include Changeable
  
  include Cloneable
  @@cloneable_associations = [:world]

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
