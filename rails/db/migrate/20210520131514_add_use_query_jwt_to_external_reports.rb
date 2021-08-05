class AddUseQueryJwtToExternalReports < ActiveRecord::Migration[4.2]
  def change
    add_column :external_reports, :use_query_jwt, :boolean, default: false
  end
end
