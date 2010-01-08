class Portal::Course < ActiveRecord::Base
  set_table_name :portal_courses
  
  acts_as_replicatable
  
  belongs_to :school, :class_name => "Portal::School", :foreign_key => "school_id"
  
  has_many :clazzes, :class_name => "Portal::Clazz", :foreign_key => "course_id", :source => :clazz
  # has_and_belongs_to_many :grade_levels, :join_table => "portal_courses_grade_levels", :class_name => "Portal::GradeLevel"

  has_many :grade_levels, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
  has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"
  
  [:district, :virtual?, :real?].each {|method| delegate method, :to=> :school } 
  
  
  self.extend SearchableModel

  @@searchable_attributes = %w{name description}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def display_name
      "Course"
    end
    
    # Try to find by course_number and title,
    def find_all_by_course_number_name_and_school_id(number,name,schoold_id)
      results = self.find_all_by_name_and_school_id(name,school_id)
      adequate = results.reject do |course|
        
      end
    end
  end
  

  
end