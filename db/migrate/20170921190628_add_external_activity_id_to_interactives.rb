class AddExternalActivityIdToInteractives < ActiveRecord::Migration
  def change
    add_column :interactives, :external_activity_id, :integer
  end
end
