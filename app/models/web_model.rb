class WebModel < ActiveRecord::Base
  belongs_to :user

  has_many :embeddable_web_models, :class_name => "Embeddable::WebModel", :foreign_key => "web_model_id", :dependent => "destroy"

  acts_as_replicatable

  include Changeable
  include HasImage
  include Publishable

  self.extend SearchableModel
  @@searchable_attributes = %w{name description url}

  def name_with_id
    "#{self.id}: #{self.name}"
  end

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def nontrasferable_attributes
      %w{id}
    end
  end
end
