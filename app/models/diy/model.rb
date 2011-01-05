class Diy::Model < ActiveRecord::Base
  set_table_name "diy_models"

  belongs_to :user
  belongs_to :model_type, :class_name => "Diy::ModelType"
  has_many :embeddable_models, :class_name =>"Embeddable::Diy::EmbeddedModel", :foreign_key => "diy_model_id", :dependent => :destroy

  validates_presence_of :model_type
  validates_presence_of :diy_id
  validates_presence_of :name
  [:otrunk_object_class, :otrunk_view_class].each { |m| delegate m, :to => :model_type }

  acts_as_taggable_on :grade_levels, :subject_areas, :tags
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
      %w"id model_type model_type_id"
    end

    def from_external_portal(_diy_model)
      found = self.find(:first, :conditions => {:diy_id => _diy_model.id})
      return found if found
      type = Diy::ModelType.from_external_portal(_diy_model.model_type)
      attributes = _diy_model.attributes

      nontrasferable_attributes.each { |na| attributes.delete(na) }
      attributes.delete_if { |k,v| (! (self.column_names.detect {|c| c == k} )) }

      if ITSI_ASSET_URL
        ## double-check model url -- if it's not absolute, prepend with the itsi asset_url
        if attributes["url"] && attributes["url"].size > 0
          attributes["url"] = ITSI_ASSET_URL.merge(attributes["url"].strip).to_s
        end

        ## also check the image url
        if attributes["image_url"] && attributes["image_url"].size > 0
          attributes["image_url"] = ITSI_ASSET_URL.merge(attributes["image_url"].strip).to_s
        end
      end

      return self.create!(attributes.update(:diy_id => _diy_model.id, :model_type => type))
    end
  end

end
