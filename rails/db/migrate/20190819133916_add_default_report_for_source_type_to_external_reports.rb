class AddDefaultReportForSourceTypeToExternalReports < ActiveRecord::Migration[5.1]
  def change
    add_column :external_reports, :default_report_for_source_type, :string, default: nil
  end
end
