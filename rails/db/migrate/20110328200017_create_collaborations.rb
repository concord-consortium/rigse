class CreateCollaborations < ActiveRecord::Migration[5.1]
  def self.up
    create_table :collaborations do |t|
      t.integer :bundle_content_id
      t.integer :student_id
      t.timestamps
    end
  end

  def self.down
    drop_table :collaborations
  end
end
