class ChangeDefaultPublicationStatusForImages < ActiveRecord::Migration
  def up
    change_column :images, :publication_status, :string, :default => "private"
  end

  def down
    change_column :images, :publication_status, :string, :default => "public"
  end

end
