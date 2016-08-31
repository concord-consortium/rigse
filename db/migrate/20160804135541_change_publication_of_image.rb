class ChangePublicationOfImage < ActiveRecord::Migration
  def up
    change_column :images, :publication_status, :string, :default => "published"
  end

  def down
    change_column :images, :publication_status, :string, :default => "private"
  end
end
