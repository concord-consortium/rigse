class AddArchiveToExternalActivity < ActiveRecord::Migration
  def change
    add_column :external_activities, :is_archived, :boolean, default: false
    add_column :external_activities, :archive_date, :datetime
  end
end
