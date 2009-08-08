class Portal::Nces06District < ActiveRecord::Base
  set_table_name :portal_nces06_districts
  
  has_many :nces_schools, :class_name => "Portal::Nces06School", :foreign_key => "nces_district_id"
end
