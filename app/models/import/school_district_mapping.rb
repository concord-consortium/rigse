class Import::SchoolDistrictMapping < ActiveRecord::Base
  self.table_name = :import_school_district_mappings
  attr_accessible :district_id, :import_district_uuid
end