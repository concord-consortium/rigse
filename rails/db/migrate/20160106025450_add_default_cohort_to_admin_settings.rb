class AddDefaultCohortToAdminSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_settings, :default_cohort_id, :integer
  end
end
