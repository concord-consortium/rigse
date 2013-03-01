class AddSchoolHoursToAdminProject < ActiveRecord::Migration
  def change
    add_column :admin_projects, :school_start_hour, :integer, :default => 8
    add_column :admin_projects, :school_end_hour,   :integer, :default => 15
  end
end
