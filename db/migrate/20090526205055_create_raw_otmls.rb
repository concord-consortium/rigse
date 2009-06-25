class CreateRawOtmls < ActiveRecord::Migration
  def self.up
    create_table :raw_otmls do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.text :otml_content

      t.timestamps
    end
  end

  def self.down
    drop_table :raw_otmls
  end
end
