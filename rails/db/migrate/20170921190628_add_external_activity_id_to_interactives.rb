class AddExternalActivityIdToInteractives < ActiveRecord::Migration[5.1]
  def change
    add_column :interactives, :external_activity_id, :integer
  end
end
