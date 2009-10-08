class Portal::District < ActiveRecord::Base
  set_table_name :portal_districts
  
  acts_as_replicatable
  
  has_many :schools, :class_name => "Portal::School", :foreign_key => "district_id"
  belongs_to :nces_district, :class_name => "Portal::Nces06District", :foreign_key => "nces_district_id"
  
  named_scope :real,    { :conditions => 'nces_district_id is NOT NULL', :include => :schools }  
  named_scope :virtual, { :conditions => 'nces_district_id is NULL', :include => :schools }  
  
  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    def display_name
      "District"
    end
  end

end