class AddIsExemplarToExternalActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :external_activities, :is_exemplar, :boolean, :default => false
  end
end
