class AddAnonymousReportToPortalOfferings < ActiveRecord::Migration
  def change
    add_column :portal_offerings, :anonymous_report, :boolean, :default => false
  end
end
