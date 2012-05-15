class Ccportal::School < Ccportal::Ccportal
  self.table_name = :portal_schools
  self.primary_key = :school_id

  has_many :teachers, :foreign_key => :member_id, :class_name => 'Ccportal::Teacher'
  has_many :courses, :foreign_key => :class_school, :class_name => 'Ccportal::Course'

  has_many :students, :foreign_key => :member_id, :class_name => 'Ccportal::Student'

  has_many :students,
    :class_name => 'Ccportal::Student',
    :finder_sql => 'SELECT DISTINCT portal_members.* FROM portal_members
    INNER JOIN portal_class_students ON portal_class_students.member_id = portal_members.member_id
    INNER JOIN portal_classes ON portal_classes.class_id = portal_class_students.class_id
    INNER JOIN portal_schools ON portal_schools.school_id = portal_classes.class_school
    WHERE portal_schools.school_id = #{id}'

  # belongs_to :district, :foreign_key => :district_id

  # This association won't work without additional processing.
  # Paul modeled the association with a varchar field named 
  # school_district in portal_schools -- not with an integer 
  # representing the district_id
  # 
  # Records up to id: 172 have a string that contains a district name:
  # 
  #   Ccportal::School.find(5).school_district
  #   => "Desert Sands Unified School District"
  #   
  # But there does not appear to actually be a district with
  # that name:
  # 
  #   Ccportal::District.find_all_by_district_name('Desert Sands Unified School District').length
  #   => 0
  # 
  # This appears to be true for many of the earlier schools.
  # 
  # Schools created later have a varchar string that contains the 
  # integer id of an associated district:
  # 
  #   Ccportal::School.find(386).school_name
  #   => "Olathe Northwest High School"
  #   
  #   Ccportal::School.find(386).school_district
  #   => "1055"
  #   
  #   Ccportal::District.find(1055).district_name
  #   => "Olathe Unified School District 233"
end
