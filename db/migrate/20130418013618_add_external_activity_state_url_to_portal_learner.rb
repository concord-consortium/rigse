class AddExternalActivityStateUrlToPortalLearner < ActiveRecord::Migration
  def change
    add_column :portal_learners, :external_activity_state_url, :string
  end
end
