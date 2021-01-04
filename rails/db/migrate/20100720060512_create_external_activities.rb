class CreateExternalActivities < ActiveRecord::Migration
  def self.up
    create_table :external_activities do |t|
      t.integer :user_id
      t.string :uuid
      t.string :name
      t.text :description
      t.text :url
      t.string :publication_status

      t.timestamps
    end
  end

  def self.down
    drop_table :external_activities
  end
end
