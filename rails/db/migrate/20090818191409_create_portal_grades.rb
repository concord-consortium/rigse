class CreatePortalGrades < ActiveRecord::Migration[5.1]
  def self.up
    create_table :portal_grades do |t|
      t.string :name
      t.string :description
      t.integer :position
      t.string :uuid
      t.boolean :active, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :portal_grades
  end
end
