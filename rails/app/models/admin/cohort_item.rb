class Admin::CohortItem < ActiveRecord::Base

  attr_accessible :admin_cohort_id, :item_id, :item_type

  self.table_name = 'admin_cohort_items'
  belongs_to :cohort, :class_name => 'Admin::Cohort', :foreign_key => "admin_cohort_id"
  belongs_to :item, polymorphic: true
end
