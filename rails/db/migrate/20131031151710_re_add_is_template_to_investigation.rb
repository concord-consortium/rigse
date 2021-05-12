class ReAddIsTemplateToInvestigation < ActiveRecord::Migration[5.1]
  def self.up
    add_column :investigations, :is_template, :boolean, :default => false
  end

  def self.down
    remove_column :investigations, :is_template
  end
end
