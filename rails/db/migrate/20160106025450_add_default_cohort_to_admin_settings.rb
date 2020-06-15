class AddDefaultCohortToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :default_cohort_id, :integer
  end
end
