class AddReportTypeToExternalReport < ActiveRecord::Migration
  def change
    add_column :external_reports, :report_type, :string, default: "offering"
  end
end
