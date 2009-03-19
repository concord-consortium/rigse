class AddDescriptionToInvestigation < ActiveRecord::Migration
  def self.up
    add_column :investigations, :description, :text
  end

  def self.down
    remove_column :investigations, :description
  end
end
