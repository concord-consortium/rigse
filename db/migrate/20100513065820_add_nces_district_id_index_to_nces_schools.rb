class AddNcesDistrictIdIndexToNcesSchools < ActiveRecord::Migration
  def self.up
    add_index :portal_nces06_schools, :nces_district_id
  end

  def self.down
    remove_index :portal_nces06_schools, :nces_district_id
  end
end
