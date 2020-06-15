class AddAllowedForStudentsToExternalReports < ActiveRecord::Migration
  def change
    add_column :external_reports, :allowed_for_students, :boolean, default: false
  end
end
