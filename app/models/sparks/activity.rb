class Sparks::Activity < ActiveRecord::Base
  set_table_name :sparks_activities
  
  belongs_to :page
  
end
