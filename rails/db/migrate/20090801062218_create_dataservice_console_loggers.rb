class CreateDataserviceConsoleLoggers < ActiveRecord::Migration
  def self.up
    create_table :dataservice_console_loggers do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :dataservice_console_loggers
  end
end
