class AddIsExemplarToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :is_exemplar, :boolean, :default => false
  end

  def self.down
    remove_column :activities, :is_exemplar
  end
end
