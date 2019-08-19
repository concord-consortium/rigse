class AddDefaultReportServiceToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :default_report_service, :string, default: "default-deprecated-api"
  end
end
