class Embeddable::WebModel < ActiveRecord::Base
  set_table_name "embeddable_web_models"

  belongs_to :user
  belongs_to :web_model, :class_name => "WebModel"

  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements

  validates_presence_of :web_model

  default_value_for :web_model do
    WebModel.find(:first)
  end

  include Changeable
  acts_as_replicatable

  [:name, :description, :url, :image_url].each {|m| delegate m, :to => :web_model }

  self.extend SearchableModel
  @@searchable_attributes = %w{uuid}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  def self.display_name
    "Web Model"
  end

  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end
end
