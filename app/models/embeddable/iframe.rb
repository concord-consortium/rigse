class Embeddable::Iframe < ActiveRecord::Base
  self.table_name = "embeddable_iframes"

  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements

  acts_as_replicatable

  include Changeable

  self.extend SearchableModel

  @@searchable_attributes = %w{name description url}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "IFrame"
  default_value_for :description, "description ..."

  send_update_events_to :investigations

  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end

end
