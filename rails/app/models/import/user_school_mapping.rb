class Import::UserSchoolMapping < ActiveRecord::Base
  self.table_name = :import_user_school_mappings
  attr_accessible :school_id, :import_school_url
end