# add indices to make Portal::TeacherPolicy, Admin::CohortPolicy, Portal::OfferingPolicy,
# and API::V1::ReportUsersController#query more performant given their non-standard complex joins
class AddUserReportIndices < ActiveRecord::Migration
  def change
    add_index :admin_cohort_items, :item_id, :name => "index_admin_cohort_items_on_item_id"
    add_index :admin_cohort_items, :item_type, :name => "index_admin_cohort_items_on_item_type"
    add_index :admin_cohort_items, :admin_cohort_id, :name => "index_admin_cohort_items_on_admin_cohort_id"

    add_index :admin_cohorts, :project_id, :name => "index_admin_cohorts_on_project_id"

    add_index :portal_offerings, :runnable_type, :name => "index_portal_offerings_on_runnable_type"
    add_index :portal_offerings, :runnable_id, :name => "index_portal_offerings_on_runnable_id"

    add_index :portal_schools, :name, :name => "index_portal_schools_on_name"
  end
end
