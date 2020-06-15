class ChangeSchoolZipcodeLimit < ActiveRecord::Migration
  def up
    change_column :portal_schools, :zipcode, :string, :limit => 20
  end

  def down
    change_column :portal_schools, :zipcode, :string, :limit => 5
  end
end
