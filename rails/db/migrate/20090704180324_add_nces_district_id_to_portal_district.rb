class AddNcesDistrictIdToPortalDistrict < ActiveRecord::Migration
  def self.up
    add_column :portal_districts, :nces_district_id, :integer
  end

  def self.down
    remove_column :portal_districts, :nces_district_id
  end
end
