class AddIsTemplateToInvestigation < ActiveRecord::Migration
  def self.up
    add_column :investigations, :is_template, :boolean
  end

  def self.down
    remove_column :investigations, :is_template
  end
end
