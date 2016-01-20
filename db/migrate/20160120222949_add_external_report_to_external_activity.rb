class AddExternalReportToExternalActivity < ActiveRecord::Migration
  def change
    add_column :external_activities, :external_report_id, :integer
  end
end
