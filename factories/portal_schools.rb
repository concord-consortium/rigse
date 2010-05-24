# belongs_to :district, :class_name => "Portal::District", :foreign_key => "district_id"
# belongs_to :nces_school, :class_name => "Portal::Nces06School", :foreign_key => "nces_school_id"
# 
# has_many :courses, :class_name => "Portal::Course", :foreign_key => "school_id"
# has_many :semesters, :class_name => "Portal::Semester", :foreign_key => "school_id"
# 
# # has_many :grade_levels, :class_name => "Portal::GradeLevel", :foreign_key => "school_id"
# 
# has_many :grade_levels, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
# has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"
# 
# has_many :school_memberships, :class_name => "Portal::SchoolMembership", :foreign_key => "school_id"

Factory.define :portal_school, :class => Portal::School do |f|
  f.name(APP_CONFIG[:site_school] || "Test School")
  f.association   :district, :factory => :portal_district
  # f.courses       { |school| [ Factory(:portal_course) ] }
  f.semesters     { |school| [ Factory(:portal_semester) ] }  
  f.grade_levels  { |school| [ Factory(:portal_grade_level) ] }  
end

Factory.define :nces_portal_school, :parent => :portal_school do |f|
  f.association   :district, :factory => :portal_nces06_district_district
  f.nces_school   { |school| Factory(:portal_nces06_school)}
end
