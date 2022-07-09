class AddSitewideAlertToAdminSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_settings, :sitewide_alert, :text, :default => nil
  end
end
