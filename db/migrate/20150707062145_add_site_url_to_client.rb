class AddSiteUrlToClient < ActiveRecord::Migration
  def up
    add_column :clients, :site_url, :string
  end
  
  def down
    remove_column :clients, :site_url
  end
end
