class Embeddable::RawOtml < ActiveRecord::Base
  set_table_name "embeddable_raw_otmls"

  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "Embeddable::RawOtml element"
  default_value_for :description, "A simple OTCompoundDoc example ..."
  default_value_for :otml_content, "<OTCompoundDoc>\n  <bodyText>\n    <div id='content'>Put your content here.</div>\n  </bodyText>\n</OTCompoundDoc>"

  def self.display_name
    "Raw Otml"
  end
  
  def self.authorable_in_java?
    true
  end

  def authorable_in_java?
    Embeddable::RawOtml.authorable_in_java?
  end


  def imports
    if @imports
      @imports
    else
      models = self.otml_content.scan(/OT\w+/)
      @imports = models.collect { |m| OtrunkExample::OtrunkImport.find_by_classname(m) }.compact
    end
  end

  def otrunk_imports
    self.imports.collect { |i| i.fq_classname }
  end
  
  # [['text_edit_edit_view', 'org.concord.otrunk.ui.OTText', 'org.concord.otrunk.ui.swing.OTTextEditEditView'], ... ]
  def otrunk_view_entries
    if @otrunk_view_entries
      @otrunk_view_entries
    else
      imports_with_views = self.imports.find_all { |import|  import.standard_view_entry }
      view_entries = imports_with_views.collect do |import|
        view_entry = import.standard_view_entry
        [view_entry.name_for_local_id, import.fq_classname, view_entry.fq_classname]
      end
      @otrunk_view_entries = view_entries
    end
  end
  
  def otrunk_edit_view_entries
    if @otrunk_edit_view_entries
      @otrunk_edit_view_entries
    else
      imports_with_views = self.imports.find_all { |import|  import.standard_edit_view_entry }
      edit_view_entries = imports_with_views.collect do |import| 
        view_entry = import.standard_edit_view_entry
        [view_entry.name_for_local_id, import.fq_classname, view_entry.fq_classname]
      end
      @otrunk_edit_view_entries = edit_view_entries
    end    
  end

end
