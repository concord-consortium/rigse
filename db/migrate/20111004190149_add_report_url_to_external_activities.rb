class AddReportUrlToExternalActivities < ActiveRecord::Migration
  def self.up
    add_column :external_activities, :report_url, :string
    add_index :external_activities, :report_url
  end

  def self.down
    remove_index :external_activities, :column => :report_url
    remove_column :external_activities, :report_url
  end
end
