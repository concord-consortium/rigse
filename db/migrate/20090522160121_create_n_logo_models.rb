class CreateNLogoModels < ActiveRecord::Migration
  def self.up
    create_table :n_logo_models do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.text :authored_data_url
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end

  def self.down
    drop_table :n_logo_models
  end
end
