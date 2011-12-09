class Embeddable::Biologica::ChromosomeZoom < ActiveRecord::Base
  set_table_name "embeddable_biologica_chromosome_zooms"

  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  has_and_belongs_to_many :organisms, :class_name => 'Embeddable::Biologica::Organism', :join_table => 'embeddable_biologica_chromosome_zooms_organisms'
  
  acts_as_replicatable

  include Changeable
  
  include Cloneable
  @@cloneable_associations = [:organisms]

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

  default_value_for :name, "Biologica Chromosome Zoom element"
  default_value_for :description, "description ..."
  default_value_for :chromosome_a_visible, true
  default_value_for :chromosome_b_visible, true
  default_value_for :chromosome_position_in_base_pairs, 0
  default_value_for :chromosome_position_in_cm, 0.0
  default_value_for :draw_genes, true
  default_value_for :draw_markers, true
  default_value_for :image_label_name_text_visible, true
  default_value_for :image_label_size, 2
  default_value_for :organism_label_type, 0
  default_value_for :zoom_level, 0

  send_update_events_to :investigations
  

  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end

end
