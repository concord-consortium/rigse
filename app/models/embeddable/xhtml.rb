class Embeddable::Xhtml < ActiveRecord::Base
  set_table_name "embeddable_xhtmls"

  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity

  acts_as_replicatable

  include Changeable
  include TruncatableXhtml
  # Including TruncatableXhtml adds a before_save hook which will automatically
  # generate a name attribute for the model instance if there is any content on 
  # the main xhtml attribute (examples: content or prompt) that can plausibly be 
  # turned into a name. Otherwise the default_value_for :name specified below is used.
  
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
  
  
  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end

end
