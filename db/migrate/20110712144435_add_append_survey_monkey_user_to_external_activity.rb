class AddAppendSurveyMonkeyUserToExternalActivity < ActiveRecord::Migration
  def self.up
    add_column :external_activities, :append_survey_monkey_uid, :boolean
  end

  def self.down
    remove_column :external_activities, :append_survey_monkey_uid
  end
end
