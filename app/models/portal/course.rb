class Portal::Course < ActiveRecord::Base
  self.table_name = :portal_courses
  
  acts_as_replicatable
  
  belongs_to :school, :class_name => "Portal::School", :foreign_key => "school_id"
  
  has_many :clazzes, :dependent => :destroy, :class_name => "Portal::Clazz", :foreign_key => "course_id", :source => :clazz
  # has_and_belongs_to_many :grade_levels, :join_table => "portal_courses_grade_levels", :class_name => "Portal::GradeLevel"

  has_many :grade_levels, :dependent => :destroy, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
  has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"
  
  [:district, :virtual?, :real?].each {|method| delegate method, :to=> :school } 
  
  
  self.extend SearchableModel

  @@searchable_attributes = %w{name description}
  
  class NonUniqueCourseNumberException < Exception 
  end
  
  class NonUniqueCourseNameException < Exception 
  end
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    
    
    #  for a given school_id:
    #  returns a course with a matching course number, OR a course with 
    #  no course number, but with a matching name.
    def find_by_course_number_name_and_school_id(number,name,school_id)
      results = self.find_all_by_course_number_and_school_id(number,school_id)
      if results && results.size == 1
        return results[0]
      end
      if results.size > 1
        raise NonUniqueCourseNumberException
      end
      
      # if we made it to here, then there were no matching coures_numbers
      # fall back to find course names that match for that school
      results = self.find_all_by_name_and_school_id(name,school_id)
      
      # to be viable, the course must have a nil course number, or 
      # or a nil course number
      results = results.select { |c| c.course_number.nil? || c.course_number == number }

      if results && results.size == 1        
        return results[0]
      end
      if results.size > 1
        raise NonUniqueCourseNameException
      end
      
      return nil # could not find anything
    end

    def find_or_create_by_course_number_name_and_school_id(number,name,school_id)
      results = find_by_course_number_name_and_school_id(number,name,school_id)
      if results 
        results.course_number = number;
        results.name = name;
        results.save
      else
        results = Portal::Course.create({
          :name => name,
          :course_number => number,
          :school_id => school_id
        })
      end
      return results
    end
  end
  
  
end