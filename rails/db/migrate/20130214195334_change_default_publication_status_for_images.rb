class ChangeDefaultPublicationStatusForImages < ActiveRecord::Migration[5.1]
  def up
    change_column :images, :publication_status, :string, :default => "private"
  end

  def down
    change_column :images, :publication_status, :string, :default => "public"
  end

end
