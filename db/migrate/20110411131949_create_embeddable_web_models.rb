class CreateEmbeddableWebModels < ActiveRecord::Migration
  def self.up
    create_table :embeddable_web_models do |t|
      t.integer :user_id
      t.integer :web_model_id
      t.string  :uuid,   :limit => 36

      t.timestamps
    end

    add_index :embeddable_web_models, :user_id
    add_index :embeddable_web_models, :web_model_id
  end

  def self.down
    remove_index :embeddable_web_models, :user_id
    remove_index :embeddable_web_models, :web_model_id
    drop_table :embeddable_web_models
  end
end
