class Portal::School < ActiveRecord::Base
  set_table_name :portal_schools
  has_settings

  acts_as_replicatable

  belongs_to :district, :class_name => "Portal::District", :foreign_key => "district_id"
  belongs_to :nces_school, :class_name => "Portal::Nces06School", :foreign_key => "nces_school_id"

  has_many :courses, :dependent => :destroy, :class_name => "Portal::Course", :foreign_key => "school_id"
  has_many :semesters, :dependent => :destroy, :class_name => "Portal::Semester", :foreign_key => "school_id"

  # has_many :grade_levels, :class_name => "Portal::GradeLevel", :foreign_key => "school_id"

  has_many :grade_levels, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
  has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"
  # has_many :clazzes, :through => :courses, :class_name => "Portal::Clazz"

  has_many :clazzes, :through => :courses, :class_name => "Portal::Clazz" do
    def active
      find(:all) & Portal::Clazz.has_offering
    end
  end

  has_many :members, :class_name => "Portal::SchoolMembership", :foreign_key => "school_id"

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
  
  # has_many_polymorphs :members, :from => [:"portal/teachers", :"portal/students"], :through => :"portal/members"
  has_many :portal_teachers, :through => :members, :source => "teacher"
  alias :teachers :portal_teachers
  named_scope :real,    { :conditions => 'nces_school_id is NOT NULL' }  
  named_scope :virtual, { :conditions => 'nces_school_id is NULL' }  

  # TODO: Maybe this?  But also maybe nces_id.nil? technique instead??
  [:virtual?, :real?].each {|method| delegate method, :to=> :district }


  include Changeable

  self.extend SearchableModel

  @@searchable_attributes = %w{uuid name description}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    ##
    ## Given an NCES local school id that matches the SEASCH field in an NCES school
    ## find and return the first district that is associated with the NCES or nil.
    ##
    ## example:
    ##
    ##   Portal::School.find_by_state_and_nces_local_id('RI', 39123).name
    ##   => "Woonsocket High School"
    ##
    def find_by_state_and_nces_local_id(state, local_id)
      nces_school = Portal::Nces06School.find(:first, :conditions => {:SEASCH => local_id, :MSTATE => state},
        :select => "id, nces_district_id, NCESSCH, LEAID, SCHNO, STID, SEASCH, SCHNAM")
      if nces_school
        find(:first, :conditions=> {:nces_school_id => nces_school.id})
      end
    end

    ##
    ## Given a school name that matches the SEASCH field in an NCES school find
    ## and return the first school that is associated with the NCES school or nil.
    ##
    ## example:
    ##
    ##   Portal::School.find_by_state_and_school_name('RI', "Woonsocket High School").nces_local_id
    ##   => "39123"
    ##
    def find_by_state_and_school_name(state, school_name)
      nces_school = Portal::Nces06School.find(:first, :conditions => {:SCHNAM => school_name.upcase, :MSTATE => state},
        :select => "id, nces_district_id, NCESSCH, LEAID, SCHNO, STID, SEASCH, SCHNAM")
      if nces_school
        find(:first, :conditions=> {:nces_school_id => nces_school.id})
      end
    end

    ##
    ## given a NCES school, find or create a portal school for it
    ##
    def find_or_create_by_nces_school(nces_school)
      found_instance = find(:first, :conditions=> {:nces_school_id => nces_school.id})
      unless found_instance
        attributes = {
          :name            => nces_school.capitalized_name,
          :description     => nces_school.description,
          :nces_school_id  => nces_school.id,
          :state           => nces_school.MSTATE,
          :ncessch         => nces_school.NCESSCH,
          :zipcode         => nces_school.MZIP,
          :district        => Portal::District.find_or_create_by_nces_district(nces_school.nces_district)
        }
        found_instance = create!(attributes)
      end
      found_instance
    end

    def find_by_similar_or_new(attrs,username='automatic process')
      found = Portal::School.find(:first, :conditions => attrs)
      unless found
        attrs[:description] ||= "created by #{username}"
        found = Portal::School.new(attrs)
      end
      return found
    end

    def find_by_similar_name_or_new(name,username='automatic process',district=Portal::District.default)
      sql = "SELECT id, name FROM portal_schools where district_id=?"
      all_names = Portal::School.find_by_sql [sql,district.id]
      found = all_names.detect { |s| s.name.upcase.gsub(/[^A-Z]/,'') == name.upcase.gsub(/[^A-Z]/,'') }
      unless found
        found = Portal::School.new(:name => name, :description => "#{name} created by #{username}")
        found.district = district
      end
      return found
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
  
  def add_member(student_or_teacher)
    # add school to the otherside of the relationship
    unless student_or_teacher.schools.include? self
      student_or_teacher.schools << self
      self.reload
    end
  end

  # if the school is a 'real' school return the NCES local school id
  def nces_local_id
    real? ? nces_school.SEASCH : nil
  end
end
