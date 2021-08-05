class CreateDataserviceConsoleContents < ActiveRecord::Migration[5.1]
  def self.up
    create_table :dataservice_console_contents do |t|
      t.integer :console_logger_id
      t.integer :position

      t.text :body
      # t.string   :sail_session_uuid, :limit => 36

      t.timestamps
    end
  end

  def self.down
    drop_table :dataservice_console_contents
  end
end
