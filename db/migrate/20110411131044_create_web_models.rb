class CreateWebModels < ActiveRecord::Migration
  def self.up
    create_table :web_models do |t|
      t.integer :user_id
      t.string  :name
      t.text    :description
      t.string  :url
      t.string  :image_url
      t.string  :publication_status
      t.string  :uuid, :limit => 36

      t.timestamps
    end

    add_index :web_models, :user_id
    add_index :web_models, :name
    add_index :web_models, :publication_status
  end

  def self.down
    remove_index :web_models, :user_id
    remove_index :web_models, :name
    remove_index :web_models, :publication_status
    drop_table :web_models
  end
end
