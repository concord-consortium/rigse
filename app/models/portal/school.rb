class Portal::School < ActiveRecord::Base
  set_table_name :portal_schools
  
  acts_as_replicatable
  
  belongs_to :district, :class_name => "Portal::District", :foreign_key => "district_id"
  belongs_to :nces_school, :class_name => "Portal::Nces06School", :foreign_key => "nces_school_id"
  
  has_many :courses, :class_name => "Portal::Course", :foreign_key => "school_id"
  has_many :semesters, :class_name => "Portal::Semester", :foreign_key => "school_id"
  has_many :grade_levels, :class_name => "Portal::GradeLevel", :foreign_key => "school_id"
  
  has_many :school_memberships, :class_name => "Portal::SchoolMembership", :foreign_key => "school_id"
  
  has_many_polymorphs :members, :from => [:"portal/teachers", :"portal/students"], :through => :"portal/school_memberships"

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    def display_name
      "School"
    end
  end
  
end