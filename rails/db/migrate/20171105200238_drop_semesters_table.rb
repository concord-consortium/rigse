class DropSemestersTable < ActiveRecord::Migration[5.1]

  def up
    drop_table :portal_semesters
  end

  def down
  end

end
