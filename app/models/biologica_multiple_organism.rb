class BiologicaMultipleOrganism < ActiveRecord::Base
  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  has_and_belongs_to_many :biologica_organisms
  
  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "Biologica Multiple Organism element"
  default_value_for :description, "description ..."
  default_value_for :height, 400
  default_value_for :width, 400

  send_update_events_to :investigations

  def self.display_name
    "Biologica Multiple Organism"
  end

  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end

end
