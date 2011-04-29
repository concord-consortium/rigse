class CreateEmbeddableDiyModels < ActiveRecord::Migration
  def self.up
    create_table :embeddable_diy_models do |t|
      t.integer   :user_id
      t.integer   :diy_model_id
      t.string    :uuid,        :limit => 36
      t.timestamps
    end
    add_index :embeddable_diy_models, :diy_model_id 
    add_index :embeddable_diy_models, :user_id
  end

  def self.down
    remove_index :embeddable_diy_models, :diy_model_id 
    remove_index :embeddable_diy_models, :user_id
    drop_table :embeddable_diy_models
  end
end
