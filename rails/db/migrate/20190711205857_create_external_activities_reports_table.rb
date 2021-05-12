

class CreateExternalActivitiesReportsTable < ActiveRecord::Migration[5.1]
  def up
    create_table :external_activity_reports, id: false do |t|
      t.references :external_activity
      t.references :external_report
    end
    add_index :external_activity_reports,
      [:external_activity_id, :external_report_id],
      name: "activity_reports_activity_index"
    add_index :external_activity_reports,
      :external_report_id,
      name: "activity_reports_index"
  end

  def down
    drop_table :external_activity_reports
  end

end
