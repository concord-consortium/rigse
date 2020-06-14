class Admin::CohortItem < ActiveRecord::Base
  self.table_name = 'admin_cohort_items'
  belongs_to :cohort, :class_name => 'Admin::Cohort', :foreign_key => "admin_cohort_id"
  belongs_to :item, polymorphic: true
end
