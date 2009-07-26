class Xhtml < ActiveRecord::Base
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity

  acts_as_replicatable

  include Changeable
  include SoftTruncate

  def before_save
    self.name = extract
  end
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name description content}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "text content"
  default_value_for :description, "description ..."
  default_value_for :content, "<p>content goes here ...</p>"

  send_update_events_to :investigations
  
  def self.display_name
    "Text Content"
  end
  
  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end

  def extract(limit=24, soft_limit=8)
    child = Hpricot.XML(content).children.first
    while child.kind_of? Hpricot::Elem
      child = child.children.first
    end
    extracted_text = child.to_s.gsub(/\s*\n/, ' ')
    soft_truncate(extracted_text, limit, soft_limit)
  end
end
