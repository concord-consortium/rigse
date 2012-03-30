class OtrunkExample::OtrunkViewEntry < ActiveRecord::Base
  self.table_name = "otrunk_example_otrunk_view_entries"
  belongs_to :otrunk_import, :class_name => 'OtrunkExample::OtrunkImport'
  has_and_belongs_to_many :otml_files, :class_name => 'OtrunkExample::OtmlFile', :uniq => true, :extend => HasOrBelongsToManyExtensions
  
  acts_as_replicatable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid classname fq_classname}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  after_create :determine_view_type
  
  def name
    view_classname
  end
  
  def name_for_local_id
    self.classname.underscore
  end
  
  
  def determine_view_type
    self.standard_edit_view = self.standard_edit_view?
    self.standard_view = self.standard_view?
    self.edit_view = self.edit_view?
    self.save
  end

  def edit_view?
    self.classname[/Edit/] != nil
  end

  def standard_edit_view?
    self.classname[/#{self.otrunk_import.classname}EditView/] != nil
  end

  def standard_view?
    self.classname[/#{self.otrunk_import.classname}View/] != nil
  end

end