class OtrunkExample::OtrunkImport < ActiveRecord::Base
  self.table_name = "otrunk_example_otrunk_imports"
  
  has_and_belongs_to_many :otml_files, :class_name => 'OtrunkExample::OtmlFile', :uniq => true, :extend => HasOrBelongsToManyExtensions
  has_and_belongs_to_many :otml_categories, :class_name => 'OtrunkExample::OtmlCategory', :uniq => true, :extend => HasOrBelongsToManyExtensions
  # has_and_belongs_to_many :otml_files, :uniq => true
  # has_and_belongs_to_many :otml_categories, :uniq => true

  has_many :otrunk_view_entries, :class_name => 'OtrunkExample::OtrunkViewEntry'
  
  acts_as_replicatable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid classname fq_classname}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  def name
    classname
  end
  
  def all_associated_imports
    self.otml_files.collect {|file| file.otrunk_imports}.flatten.uniq
  end

  def all_associated_view_entries
    self.all_associated_imports.collect { |import| import.otrunk_view_entries }.flatten.uniq
  end
  
  def standard_view_entry
    self.otrunk_view_entries.detect { |ve| ve.standard_view? }
  end
  
  def standard_edit_view_entry
    self.otrunk_view_entries.detect { |ve| ve.standard_edit_view? }
  end

end
