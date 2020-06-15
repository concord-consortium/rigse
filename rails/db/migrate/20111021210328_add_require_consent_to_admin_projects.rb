class AddRequireConsentToAdminProjects < ActiveRecord::Migration
  def self.up
    add_column :admin_projects, :require_user_consent, :boolean, :default => false
  end

  def self.down
    remove_column :admin_projects, :require_user_consent
  end
end
