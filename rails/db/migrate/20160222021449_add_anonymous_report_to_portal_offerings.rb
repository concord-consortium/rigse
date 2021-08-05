class AddAnonymousReportToPortalOfferings < ActiveRecord::Migration[5.1]
  def change
    add_column :portal_offerings, :anonymous_report, :boolean, :default => false
  end
end
