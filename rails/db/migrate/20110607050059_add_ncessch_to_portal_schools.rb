class AddNcesschToPortalSchools < ActiveRecord::Migration
  def self.up
    add_column    :portal_schools, :ncessch,         :string, :limit => 12
    remove_column :portal_schools, :leaid_schoolnum
  end

  def self.down
    remove_column :portal_schools, :ncessch
    add_column    :portal_schools, :leaid_schoolnum, :string, :limit => 12
  end
end
