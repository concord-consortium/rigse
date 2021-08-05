class AddPublicationStatusToInvestigations < ActiveRecord::Migration[5.1]
  def self.up
    add_column :investigations, :publication_status, :string
  end

  def self.down
    remove_column :investigations, :publication_status
  end
end
