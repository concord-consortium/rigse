class AddIndividualReportableToExternalReports < ActiveRecord::Migration
  def change
    add_column :external_reports, :individual_student_reportable, :boolean, default: false
    add_column :external_reports, :individual_activity_reportable, :boolean, default: false
  end
end
