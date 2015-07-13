class Embeddable::Diy::EmbeddedModel < Embeddable::Embeddable
  set_table_name "embeddable_diy_models"
  belongs_to :diy_model, :class_name => "::Diy::Model"

  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements

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
    if (diy_model.interactive_url && !diy_model.interactive_url.empty?) || (Labbook.enabled? && otrunk_object_class == "org.concord.otrunk.ui.OTBrowseableImage")
      return true
    else
      return false
    end
  end

  def export_as_lara_activity
   {
      :name => self.name,
      :native_height => self.diy_model.interactive_height,
      :native_width => self.diy_model.interactive_width,
      :url => self.diy_model.interactive_url,
      :type => "MwInteractive",
      :click_to_play => true,
      :image_url => self.diy_model.image_url,
      :ref_id => id
    }
  end

end
