class AddCountryToPortalSchools < ActiveRecord::Migration[5.1]
  def change
    add_column :portal_schools, :country_id, :integer
  end
end
