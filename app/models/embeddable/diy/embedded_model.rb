class Embeddable::Diy::EmbeddedModel < Embeddable::Embeddable
  set_table_name "embeddable_diy_models"
  belongs_to :diy_model, :class_name => "::Diy::Model"

  validates_presence_of :diy_model

  [:name, :description, :url, :width, :height, :otrunk_object_class, :otrunk_view_class, :otrunk_object_class_short, :sizeable].each { |m| delegate m, :to => :diy_model }

  @@searchable_attributes = %w{uuid}
  
  include Snapshotable
  
  self.extend SearchableModel
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  def self.display_name
    "Model"
  end
  
  def can_run_lightweight?
    if diy_model.interactive_url || otrunk_object_class == "org.concord.otrunk.ui.OTBrowseableImage"
      return true
    else
      return false
    end
  end

end
