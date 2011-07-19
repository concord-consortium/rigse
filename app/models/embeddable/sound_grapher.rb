class Embeddable::SoundGrapher < ActiveRecord::Base
  set_table_name "embeddable_sound_graphers"

  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity

  def self.valid_display_modes
    %w[Waves Frequencies]
  end

  def self.valid_max_frequencies
    %w[1000 2000 3000 4000 5000 6000 7000 8000]
  end

  def self.valid_max_sample_times
    %w[30 60 100 200]
  end

  validates_inclusion_of :display_mode,    :in => self.valid_display_modes
  validates_inclusion_of :max_frequency,   :in => self.valid_max_frequencies
  validates_inclusion_of :max_sample_time, :in => self.valid_max_sample_times

  acts_as_replicatable
  send_update_events_to :investigations

  include Changeable

  self.extend SearchableModel

  @@searchable_attributes = %w{name}

  def self.searchable_attributes
      @@searchable_attributes
  end
  
  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end

  default_value_for :name, "Sound Grapher"
  default_value_for :display_mode, self.valid_display_modes.first
  default_value_for :max_frequency, self.valid_max_frequencies.first
  default_value_for :max_sample_time, self.valid_max_sample_times.first

  def self.display_name
    "Sound Grapher"
  end


end
