class CreateNotificationsAssessmentImportInfos < ActiveRecord::Migration
  def self.up
    create_table :notifications_assessment_import_infos do |t|
      t.string :database
      t.integer :last_seq

      t.timestamps
    end

    add_index :notifications_assessment_import_infos, :database
  end

  def self.down
    remove_index :notifications_assessment_import_infos, :database
    drop_table :notifications_assessment_import_infos
  end
end
