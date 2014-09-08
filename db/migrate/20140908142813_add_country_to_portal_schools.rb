class AddCountryToPortalSchools < ActiveRecord::Migration
  def change
    add_column :portal_schools, :country_id, :integer
  end
end
