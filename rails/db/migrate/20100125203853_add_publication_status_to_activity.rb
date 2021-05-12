class AddPublicationStatusToActivity < ActiveRecord::Migration[5.1]
  def self.up
    add_column :activities, :publication_status, :string
  end

  def self.down
    remove_column :activities, :publication_status
  end
end
