class ChangeStateSizeInPortalSchools < ActiveRecord::Migration[5.1]
	change_column :portal_schools, :state, :string, :limit => 80
end
