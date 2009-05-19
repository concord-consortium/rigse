class CreateMwModelerPages < ActiveRecord::Migration
  def self.up
    create_table :mw_modeler_pages do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.text :authored_data_url

      t.timestamps
    end
  end

  def self.down
    drop_table :mw_modeler_pages
  end
end
