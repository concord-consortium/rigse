class CreateDiyModelType < ActiveRecord::Migration
  def self.up
    create_table :diy_model_types, :force => true do |t|
      t.string  :name
      t.text    :description
      t.string  :url
      t.string  :image_url
      t.text    :credits
      t.string  :otrunk_object_class
      t.string  :otrunk_view_class
      t.boolean :authorable
      t.integer :diy_id
      t.integer :user_id
      t.boolean :sizeable
      t.string  :uuid
    end
    add_index :diy_model_types, :user_id
    add_index :diy_model_types, :diy_id
  end

  def self.down
    remove_index :diy_model_types, :user_id
    remove_index :diy_model_types, :diy_id
    drop_table :diy_model_types
  end
end
