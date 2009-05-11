class RecreateInvestigations < ActiveRecord::Migration
  def self.up
    create_table :investigations do |t|
      t.integer :user_id
      t.column :uuid, :string, :limit => 36

      t.string :name
      t.text   :description

      t.timestamps
    end    
  end

  def self.down
    drop_table :investigations
  end
end
