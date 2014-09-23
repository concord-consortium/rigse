class ChangeStateSizeInPortalSchools < ActiveRecord::Migration
	change_column :portal_schools, :state, :string, :limit => 80
end
