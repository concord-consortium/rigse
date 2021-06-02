class AddUseQueryJwtToExternalReports < ActiveRecord::Migration
  def change
    add_column :external_reports, :use_query_jwt, :boolean, default: false
  end
end
