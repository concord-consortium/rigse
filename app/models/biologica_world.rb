class BiologicaWorld < ActiveRecord::Base
  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  has_many :biologica_organisms
  
  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  @@available_species_paths = {
    "Arabidopsis" => "org/concord/biologica/worlds/arabidopsis.xml",
    "Budgie" => "org/concord/biologica/worlds/budgie.xml",
    "Dragon" => "org/concord/biologica/worlds/dragon.xml",
    "Drake" => "org/concord/biologica/worlds/drake.xml",
    "Fish" => "org/concord/biologica/worlds/fishworld.xml",
    "Hamster" => "org/concord/biologica/worlds/hamster.xml",
    "Simple Pea" => "org/concord/biologica/worlds/peasimple.xml",
    "Pisum Sativum" => "org/concord/biologica/worlds/pisum.xml"
  }
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    def available_species_paths
      @@available_species_paths
    end
  end

  default_value_for :name, "Biologica World element"
  default_value_for :description, "description ..."
  default_value_for :species_path, @@available_species_paths['Dragon']

  def self.display_name
    "Biologica World"
  end


end
