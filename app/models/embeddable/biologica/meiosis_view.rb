class Embeddable::Biologica::MeiosisView < ActiveRecord::Base
  set_table_name "embeddable_biologica_meiosis_views"

  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  belongs_to :father_organism, :class_name => "Embeddable::Biologica::Organism"
  belongs_to :mother_organism, :class_name => "Embeddable::Biologica::Organism"
  
  acts_as_replicatable

  include Changeable
  
  include Cloneable
  @@cloneable_associations = [:father_organism, :mother_organism]

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    def cloneable_associations
      @@cloneable_associations
    end
  end

  default_value_for :name, "Biologica Meiosis View element"
  default_value_for :description, "description ..."
  default_value_for :width, 400
  default_value_for :height, 400
  default_value_for :replay_button_enabled, true
  default_value_for :controlled_crossover_enabled, false
  default_value_for :crossover_control_visible, false
  default_value_for :controlled_alignment_enabled, false
  default_value_for :alignment_control_visible, false

  send_update_events_to :investigations


  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end

end
