class DropInstallerReports < ActiveRecord::Migration[5.1]
  def self.up
    drop_table :installer_reports
  end

  def self.down
    create_table :installer_reports do |t|
      t.text :body
      t.string :remote_ip
      t.boolean :success
      t.integer :jnlp_session_id
      t.timestamps
    end
  end
end
