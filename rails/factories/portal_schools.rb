# belongs_to :district, :class_name => "Portal::District", :foreign_key => "district_id"
# belongs_to :nces_school, :class_name => "Portal::Nces06School", :foreign_key => "nces_school_id"
# 
# has_many :courses, :class_name => "Portal::Course", :foreign_key => "school_id"
# 
# # has_many :grade_levels, :class_name => "Portal::GradeLevel", :foreign_key => "school_id"
# 
# has_many :grade_levels, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
# has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"
# 
# has_many :school_memberships, :class_name => "Portal::SchoolMembership", :foreign_key => "school_id"

FactoryBot.define do
  factory :portal_school, :class => Portal::School do |f|
    f.name {APP_CONFIG[:site_school] || "Test School"}
    f.association :district, :factory => :portal_district
    f.grade_levels {|school| [FactoryBot.create(:portal_grade_level)]}
  end
end

FactoryBot.define do
  factory :nces_portal_school, :parent => :portal_school do |f|
    f.association :district, :factory => :portal_nces06_district_district
    f.nces_school {FactoryBot.create(:portal_nces06_school)}
  end
end
