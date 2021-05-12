class RemoveReportUrlFromExternalActivities < ActiveRecord::Migration[5.1]
  def up
    remove_column :external_activities, :report_url
  end

  def down
    add_column :external_activities, :report_url, :string
  end
end
