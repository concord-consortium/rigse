class Portal::Clazz < ActiveRecord::Base
  set_table_name :portal_clazzes
  
  acts_as_replicatable
  
  belongs_to :course, :class_name => "Portal::Course", :foreign_key => "course_id"
  belongs_to :semester, :class_name => "Portal::Semester", :foreign_key => "semester_id"
  belongs_to :teacher, :class_name => "Portal::Teacher", :foreign_key => "teacher_id"
  
  has_many :offerings, :class_name => "Portal::Offering", :foreign_key => "clazz_id"
  has_many :student_clazzes, :class_name => "Portal::StudentClazz", :foreign_key => "clazz_id"
  
  has_many :students, :through => :student_clazzes, :class_name => "Portal::Student"
  
  has_many :grade_levels, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
  has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"
  
  [:district, :virtual?, :real?].each {|method| delegate method, :to=> :course } 

  validates_presence_of :class_word
  validates_uniqueness_of :class_word

  include Changeable

  self.extend SearchableModel

  @@searchable_attributes = %w{name description}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def display_name
      "Class"
    end
  end
  
  def self.find_or_create_by_course_and_section_and_start_date(portal_course,section,start_date)
    raise "argument portal_course was null or empty" unless portal_course && portal_course.id
    
    if start_date.class != DateTime
      Rails.logger.warn("Found non-dateTime object in find_or_create_by_course_and_section_and_start_date")
      start_date = start_date.to_datetime
    end
    found = nil
    clazzes = portal_course.clazzes.select { |clazz| clazz.section == section && clazz.start_time == start_date }
    if clazzes.size > 0
      found = clazzes[0]
      if clazzes.size > 1
        Rails.logger.error("too many clazzes with the same section and start date for #{portal_course.name} (#{clazzes.size})")
      end
    else
      params = {
        :section => section, 
        :start_time => start_date, 
        :class_word => random_class_word(portal_course),
        :name => portal_course.name
      }
      found = Portal::Clazz.create(params)
      found.save!
      portal_course.clazzes << found
    end
    found
  end
  
  def self.random_class_word(course)
    string = (0..5).map{ ('a'..'z').to_a[rand(26)] }.join
    "#{course.id}_#{string}"
  end
  
  def title
    semester_name = semester ? semester.name : 'unknown'
    "Class: #{name}, Semester: #{semester_name}"
  end
  
  # for the accordion display
  def children
    return students
  end
  
  def user
    return teacher.user
  end
    
  def parent
    return teacher
  end
  

end