class AddResearcherOptionToExternalReports < ActiveRecord::Migration[6.1]
  def change
    add_column :external_reports, :supports_researchers, :boolean, :default => false
  end
end
