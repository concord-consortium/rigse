class AddPublicationStatusToSectionsAndPages < ActiveRecord::Migration
  def self.up
    add_column :sections, :publication_status, :string
    add_column :pages,    :publication_status, :string
  end

  def self.down
    remove_column :sections, :publication_status
    remove_column :pages,    :publication_status
  end
end
