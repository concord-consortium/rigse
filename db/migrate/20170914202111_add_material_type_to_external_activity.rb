class AddExternalTypeToExternalActivity < ActiveRecord::Migration
  def change
    add_column :external_activities, :material_type, :string
  end
end
