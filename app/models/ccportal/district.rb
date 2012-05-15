class Ccportal::District < Ccportal::Ccportal
  self.table_name = :portal_districts
  self.primary_key = :district_id

  # has_many :schools, :foreign_key => :school_district

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
