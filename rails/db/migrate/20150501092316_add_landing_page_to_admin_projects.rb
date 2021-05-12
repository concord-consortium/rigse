class AddLandingPageToAdminProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_projects, :landing_page_slug, :string
    add_column :admin_projects, :landing_page_content, :text

    add_index :admin_projects, :landing_page_slug, unique: true
  end
end
