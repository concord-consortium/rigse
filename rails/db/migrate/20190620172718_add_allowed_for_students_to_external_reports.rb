class AddAllowedForStudentsToExternalReports < ActiveRecord::Migration[5.1]
  def change
    add_column :external_reports, :allowed_for_students, :boolean, default: false
  end
end
