class Embeddable::WebModel < ActiveRecord::Base
  set_table_name "embeddable_web_models"

  belongs_to :user
  belongs_to :web_model, :class_name => "WebModel"

  validates_presence_of :web_model

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
end
