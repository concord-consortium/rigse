class BiologicaMeiosisView < ActiveRecord::Base
  
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

  default_value_for :name, "Biologica Meiosis View element"
  default_value_for :description, "description ..."
  default_value_for :width, 400
  default_value_for :height, 400
  default_value_for :replay_button_enabled, true
  default_value_for :controlled_crossover_enabled, false
  default_value_for :crossover_control_visible, false
  default_value_for :controlled_alignment_enabled, false
  default_value_for :alignment_control_visible, false

  def self.display_name
    "Biologica Meiosis View"
  end


end
