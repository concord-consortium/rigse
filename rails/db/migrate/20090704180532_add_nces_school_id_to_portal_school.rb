class AddNcesSchoolIdToPortalSchool < ActiveRecord::Migration[5.1]
  def self.up
    add_column :portal_schools, :nces_school_id, :integer
  end

  def self.down
    remove_column :portal_schools, :nces_school_id
  end
end
