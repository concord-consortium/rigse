class OtrunkExample::OtmlCategory < ActiveRecord::Base
  set_table_name "otrunk_example_otml_categories"
  has_many :otml_files, :class_name => 'OtrunkExample::OtmlFile'
  has_and_belongs_to_many :otrunk_imports, :uniq => true, :extend => HasOrBelongsToManyExtensions

  acts_as_replicatable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
end
