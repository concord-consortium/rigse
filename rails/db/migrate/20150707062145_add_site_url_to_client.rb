class AddSiteUrlToClient < ActiveRecord::Migration[5.1]
  def up
    add_column :clients, :site_url, :string
  end
  
  def down
    remove_column :clients, :site_url
  end
end
