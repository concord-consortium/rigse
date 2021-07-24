class AddReportTypeToExternalReport < ActiveRecord::Migration[5.1]
  def change
    add_column :external_reports, :report_type, :string, default: "offering"
  end
end
