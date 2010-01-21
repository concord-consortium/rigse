class Portal::Clazz < ActiveRecord::Base
  set_table_name :portal_clazzes
  
  acts_as_replicatable
  
  belongs_to :course, :class_name => "Portal::Course", :foreign_key => "course_id"
  belongs_to :semester, :class_name => "Portal::Semester", :foreign_key => "semester_id"
  # belongs_to :teacher, :class_name => "Portal::Teacher", :foreign_key => "teacher_id"
  
  has_many :offerings, :class_name => "Portal::Offering", :foreign_key => "clazz_id"
  
  has_many :student_clazzes, :class_name => "Portal::StudentClazz", :foreign_key => "clazz_id"
  has_many :students, :through => :student_clazzes, :class_name => "Portal::Student"
  
  has_many :teacher_clazzes, :class_name => "Portal::TeacherClazz", :foreign_key => "clazz_id"
  has_many :teachers, :through => :teacher_clazzes, :class_name => "Portal::Teacher"
  
  has_many :grade_levels, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
  has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"
  

  validates_presence_of :class_word
  validates_uniqueness_of :class_word

  #TODO: alias chain changeable? to check all teachers, but honor PortalChangable
  include PortalChangeable

  self.extend SearchableModel

  @@searchable_attributes = %w{name description}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def display_name
      "Class"
    end
    
    # TODO: Should this go here?
    # We want to crate a clazz to test data saving and loading
    #
    def data_test_clazz
      class_word = '__XyZZy__'
      clazz = Portal::Clazz.find_by_class_word(class_word)
      if clazz
        # TODO: clean this up!
        # Just in case the existing investigation created for testing needs
        # to be updated -- make sure we have the right text in the xhtml
        # because the test relies on the object having the right name and
        # the name is generated from text in the xhtml prompt.
        open_response = clazz.offerings[0].runnable.open_responses.first
        open_response.prompt = "test_text"
        open_response.save!
      else
        clazz = Portal::Clazz.create(
          :name => 'Data test class',
          :class_word => class_word
        )
        investigation = Investigation.create( {
          :name => 'Data test'
        })


        activity = Activity.create(:name => 'Data testing Activity')
        activity.investigation = investigation
        activity.save

        section = Section.create(:name => "data testing section")
        section.activity = activity
        section.save

        page = Page.create(:name => 'data testing page')
        page.section = section
        page.save

        xhtml = Embeddable::Xhtml.create(:name => 'data testing xhtml')
        xhtml.save
        page.xhtmls << xhtml
        
        # The prompt gets used as the "name" for the open response, and the OTText's name gets set to #{prompt}_field
        # The Java test looks for a text box named "test_text_field"
        open_response = Embeddable::OpenResponse.create(:prompt => "test_text");
        open_response.save
        page.open_responses << open_response
        page.save

        investigation.user = User::site_admin
        investigation.save

        offering = Portal::Offering.create()
        offering.runnable = investigation;
        offering.clazz = clazz
        offering.save
        clazz.save
        clazz.reload
      end
      clazz 
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
    # return students
    return offerings
  end
  
  def user
    if self.teacher
      return self.teacher.user
    end
    nil
  end
  
  # this is for changeable?
  # changeable_mod for multiple teachers
  alias _changeable? changeable?
  def is_user?(_user)
    teacher = _user.class == User ? _user.portal_teacher : _user
    teachers.include? teacher
  end
  alias is_teacher? is_user?
  
  def changeable?(_user)
    return true if virtual? && is_user?(_user)
    if _user.has_role?('manager','admin','district_admin')
      return true
    end
    return false
  end
    
    
  def parent
    return teacher
  end
  
  # 
  # [:district, :virtual?, :real?].each {|method| delegate method, :to=> :course } 
  
  def district
    if course
      return course.district
    end
    return nil
  end
  
  def virtual?
    if course
      return course.virtual?
    end
    return true
  end
  
  def real?
    return (! virtual?)
  end
  
  # HACK: to support transitioning to multiple teachers.
  def teacher
    self.teachers.first
  end
  
  # HACK: to support transitioning to multiple teachers.  
  def teacher=(_teacher)
    add_teacher(_teacher)
  end
  
  def has_teacher?(_teacher)
    self.teachers.detect { |t| t.id == _teacher.id }
  end
  
  def add_teacher(_teacher)
    unless self.has_teacher?(_teacher)
      self.teachers << _teacher
    end
  end

end