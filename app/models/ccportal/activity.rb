class Ccportal::Activity < Ccportal::Ccportal
  set_table_name :portal_activities
  set_primary_key :activity_id
  
  belongs_to :level, :foreign_key => :activity_level, :class_name => 'Ccportal::Level'
  belongs_to :unit, :foreign_key => :activity_unit, :class_name => 'Ccportal::Unit'
  belongs_to :subject, :foreign_key => :activity_subject, :class_name => 'Ccportal::Subject'

  has_many :class_activities, :foreign_key => :activity_id, :class_name => 'Ccportal::ClassActivity'
  has_many :courses, :through => :class_activities, :class_name => 'Ccportal::Course'
  
  has_many :modified_times, :foreign_key => :activity_id, :class_name => "ModifiedTime" do
    def by_student(student)
      find(:all, :conditions => {:student_id => student.id})
    end
  end

  @@activities = nil #cache
  
  def self.findAll
    @@activities = @@activities.nil? ? self.all : @@activities
  end

  def self.findAllByClassId(classId)
    Ccportal::ClassActivity.findActivities(classId)
  end
  
  def self.clearCache
    @@allActivities = nil
  end
  
end
