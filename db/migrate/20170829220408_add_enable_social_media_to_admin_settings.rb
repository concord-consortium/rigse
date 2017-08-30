class AddEnableSocialMediaToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :enable_social_media, :boolean, :default => true
  end
end
