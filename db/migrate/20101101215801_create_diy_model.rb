class CreateDiyModel < ActiveRecord::Migration
  def self.up
    create_table :diy_models, :force => true do |t|
      t.integer :user_id
      t.integer :diy_id
      t.integer :model_type_id
      t.string  :name
      t.string  :url
      t.string  :image_url
      t.boolean :public
      t.string  :publication_status 
      t.text    :description
      t.text    :instructions
      t.boolean :snapshot_active
      t.text    :credits
      t.string  :uuid
      t.string  :short_name
      t.integer :height
      t.integer :width
      t.integer :version
    end
    add_index :diy_models, :user_id
    add_index :diy_models, :name
    add_index :diy_models, :diy_id
    add_index :diy_models, :public
    add_index :diy_models, :model_type_id

  end

  def self.down
    remove_index :diy_models, :user_id
    remove_index :diy_models, :name
    remove_index :diy_models, :diy_id
    remove_index :diy_models, :public
    remove_index :diy_models, :model_type_id
    drop_table :diy_models
  end
end
