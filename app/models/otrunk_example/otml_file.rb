class OtrunkExample::OtmlFile < ActiveRecord::Base
  self.table_name = "otrunk_example_otml_files"
  has_and_belongs_to_many :otrunk_imports, :class_name => 'OtrunkExample::OtrunkImport', :uniq => true, :extend => HasOrBelongsToManyExtensions
  has_and_belongs_to_many :otrunk_view_entries, :class_name => 'OtrunkExample::OtrunkViewEntry', :uniq => true, :extend => HasOrBelongsToManyExtensions
  belongs_to :otml_category, :class_name => 'OtrunkExample::OtmlCategory'
  
  acts_as_replicatable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
end