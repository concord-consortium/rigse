class AddCityToPortalSchools < ActiveRecord::Migration[5.1]
  def change
    add_column :portal_schools, :city, :text
  end
end
