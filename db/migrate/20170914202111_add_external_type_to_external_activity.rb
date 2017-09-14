class AddExternalTypeToExternalActivity < ActiveRecord::Migration
  def change
    add_column :external_activities, :external_type, :string
  end
end
