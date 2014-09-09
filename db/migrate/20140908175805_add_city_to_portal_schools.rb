class AddCityToPortalSchools < ActiveRecord::Migration
  def change
    add_column :portal_schools, :city, :text
  end
end
