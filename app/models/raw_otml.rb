class RawOtml < ActiveRecord::Base
  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "RawOtml element"
  default_value_for :description, "description ..."
  default_value_for :content, "<OTCompoundDoc><bodyText><div id='content'>Put your content here.</div></bodyText></OTCompoundDoc>"

  def self.display_name
    "Raw Otml"
  end


end
