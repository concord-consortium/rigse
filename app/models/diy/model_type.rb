class Diy::ModelType < ActiveRecord::Base
  set_table_name "diy_model_types"

  belongs_to :user
  has_many :models, :as => :embeddable, :class_name => "Diy::Model"
  validates_presence_of :name
  #validates_format_of :otrunk_object_class, :with =>/\AOT/
  #validates_format_of :otrunk_view_class, :with =>/\AOT/
  #validates_presence_of :description
  validates_presence_of :diy_id
  validates_presence_of :otrunk_view_class
  validates_presence_of :otrunk_object_class

  acts_as_replicatable
  include Changeable
  include HasImage
  self.extend SearchableModel
  @@searchable_attributes = %w{name description credits}

  def otrunk_object_class_short
    self.otrunk_object_class[/\.([^\.]*)$/,1]
  end

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    
    def nontrasferable_attributes
      %w"id previous_user_id parent_version"
    end

    def from_external_portal(_diy_model_type)
      found = self.find(:first, :conditions => {:diy_id => _diy_model_type.id})
      return found if found
      attributes = _diy_model_type.attributes
      nontrasferable_attributes.each { |na| attributes.delete(na) }
      return self.create!(attributes.update(:diy_id => _diy_model_type.id))
    end
  end

end
