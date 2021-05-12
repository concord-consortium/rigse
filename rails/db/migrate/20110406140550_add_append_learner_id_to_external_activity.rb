class AddAppendLearnerIdToExternalActivity < ActiveRecord::Migration[5.1]
  def self.up
    add_column :external_activities, :append_learner_id_to_url, :boolean
  end

  def self.down
    remove_column :external_activities, :append_learner_id_to_url
  end
end
