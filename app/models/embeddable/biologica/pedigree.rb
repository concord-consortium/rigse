class Embeddable::Biologica::Pedigree < ActiveRecord::Base
  set_table_name "embeddable_biologica_pedigrees"

  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  has_and_belongs_to_many :organisms, :class_name => 'Embeddable::Biologica::Organism', :join_table => 'embeddable_biologica_organisms_pedigrees'
  
  acts_as_replicatable

  include Changeable
  
  cloneable_associations :organisms

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  @@available_image_sizes = {
    "XXSMALL"	=> 0,
    "XSMALL"	=> 1,
    "SMALL"	=> 2,
    "MEDIUM"	=> 3,
    "LARGE"	=> 4,
    "XLARGE"	=> 5
  }
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    def available_image_sizes
      @@available_image_sizes
    end
  end

  default_value_for :name, "Biologica Pedigree element"
  default_value_for :description, "description ..."
  default_value_for :height, 400
  default_value_for :width, 400
  default_value_for :crossover_enabled, false
  default_value_for :sex_text_visible, false
  default_value_for :organism_images_visible, false
  default_value_for :organism_image_size, 0
  default_value_for :top_controls_visible, true
  default_value_for :reset_button_visible, true
  default_value_for :minimum_number_children, 3
  default_value_for :maximum_number_children, 5

  send_update_events_to :investigations


  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end

end
