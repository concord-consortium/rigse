class AddFieldsToPortalSchoolAndDistrict < ActiveRecord::Migration
  def self.up
    add_column :portal_districts, :state, :string, :limit => 2
    add_column :portal_districts, :leaid, :string, :limit => 7
    add_column :portal_districts, :zipcode, :string, :limit => 5

    add_column :portal_schools, :state, :string, :limit => 2
    add_column :portal_schools, :leaid_schoolnum, :string, :limit => 12
    add_column :portal_schools, :zipcode, :string, :limit => 5
    
    add_index :portal_districts, :state
    add_index :portal_schools, :state    
  end

  def self.down
    remove_index :portal_districts, :state
    remove_index :portal_schools, :state
    
    remove_column :portal_districts, :state
    remove_column :portal_districts, :leaid
    remove_column :portal_districts, :zipcode

    remove_column :portal_schools, :state
    remove_column :portal_schools, :leaid_schoolnum
    remove_column :portal_schools, :zipcode
  end
end
