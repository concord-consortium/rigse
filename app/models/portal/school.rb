class Portal::School < ActiveRecord::Base
  set_table_name :portal_schools
  
  acts_as_replicatable
  
  belongs_to :district, :class_name => "Portal::District", :foreign_key => "district_id"
  belongs_to :nces_school, :class_name => "Portal::Nces06School", :foreign_key => "nces_school_id"
  
  has_many :courses, :class_name => "Portal::Course", :foreign_key => "school_id"
  has_many :semesters, :class_name => "Portal::Semester", :foreign_key => "school_id"

  # has_many :grade_levels, :class_name => "Portal::GradeLevel", :foreign_key => "school_id"

  has_many :grade_levels, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
  has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"
  
  has_many :school_memberships, :class_name => "Portal::SchoolMembership", :foreign_key => "school_id"

  # because of has_many polyporphs this means the the associations look like this:
  #
  #   school.portal_teachers
  #   school.portal_students
  #
  # but from the other side the 'portal' scoping isn't in the relationship
  #
  #   teacher.schools
  #   student.schools
  #
  
  has_many_polymorphs :members, :from => [:"portal/teachers", :"portal/students"], :through => :"portal/school_memberships"

  named_scope :real,    { :conditions => 'nces_school_id is NOT NULL' }  
  named_scope :virtual, { :conditions => 'nces_school_id is NULL' }  

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
  
  ##
  ## Strange approach to alter the behavior of Clazz.children()
  ## to reflect a student-centric world view.
  ## ... (possibly a bad idea?)
  module FixupClazzes
    def parents
      return offerings
    end
  end
    
  ##
  ## required for the accordion view
  ##
  def children
    clazzes.map! {|c| c.extend(FixupClazzes)}
  end
  
  def children
    clazzes
  end
  
  ##
  ## sort of a hack
  ##
  def parent
    nil
  end
end