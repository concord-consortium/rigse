class AddRequireConsentToAdminProjects < ActiveRecord::Migration[5.1]
  def self.up
    add_column :admin_projects, :require_user_consent, :boolean, :default => false
  end

  def self.down
    remove_column :admin_projects, :require_user_consent
  end
end
