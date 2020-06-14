class CreateInstallerReports < ActiveRecord::Migration
  def self.up
    create_table :installer_reports do |t|
      t.text :body
      t.string :remote_ip
      t.boolean :success

      t.timestamps
    end
  end

  def self.down
    drop_table :installer_reports
  end
end
