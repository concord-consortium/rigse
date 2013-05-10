class AddIsExemplarToExternalActivity < ActiveRecord::Migration
  def change
    add_column :external_activities, :is_exemplar, :boolean, :default => false
  end
end
