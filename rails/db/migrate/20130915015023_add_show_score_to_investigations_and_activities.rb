class AddShowScoreToInvestigationsAndActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :investigations,      :show_score, :boolean, :default => false
    add_column :activities,          :show_score, :boolean, :default => false
  end
end
