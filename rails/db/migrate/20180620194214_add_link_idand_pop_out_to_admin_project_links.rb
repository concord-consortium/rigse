class AddLinkIdandPopOutToAdminProjectLinks < ActiveRecord::Migration
  def change
    add_column :admin_project_links, :link_id, :string
    add_column :admin_project_links, :pop_out, :boolean
  end
end
