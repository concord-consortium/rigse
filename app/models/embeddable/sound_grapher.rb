class Embeddable::SoundGrapher < ActiveRecord::Base
  set_table_name "embeddable_sound_graphers"
  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "Sound Grapher"

  def self.display_name
    "Sound Grapher"
  end

end
