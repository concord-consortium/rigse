class OtrunkExample::OtmlCategory < ActiveRecord::Base
  self.table_name = "otrunk_example_otml_categories"
  has_many :otml_files, :class_name => 'OtrunkExample::OtmlFile'
  has_and_belongs_to_many :otrunk_imports, :class_name => 'OtrunkExample::OtrunkImport', :uniq => true, :extend => HasOrBelongsToManyExtensions
  # has_and_belongs_to_many :otrunk_imports, :uniq => true

  acts_as_replicatable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
end
