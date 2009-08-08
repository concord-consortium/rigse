class Portal::Nces06School < ActiveRecord::Base
  set_table_name :portal_nces06_schools
  
  belongs_to :nces_district, :class_name => "Portal::Nces06District", :foreign_key => "nces_district_id"
end
