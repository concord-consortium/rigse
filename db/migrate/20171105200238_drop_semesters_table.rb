class DropSemestersTable < ActiveRecord::Migration

  def up
    drop_table :portal_semesters
  end

  def down
  end

end
