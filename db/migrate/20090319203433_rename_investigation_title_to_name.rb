class RenameInvestigationTitleToName < ActiveRecord::Migration

  def self.up
    rename_column :investigations, :title, :name
  end

  def self.down
    rename_column :investigations, :name, :title
  end
end
