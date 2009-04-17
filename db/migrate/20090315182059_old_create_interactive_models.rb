class CreateInteractiveModels < ActiveRecord::Migration
  def self.up
    create_table :interactive_models do |t|
      t.integer     :user_id
      t.string      :uuid,         :limit => 36

      t.string      :name
      t.text        :description
      t.string      :content
      
      t.timestamps
    end
  end

  def self.down
    drop_table :interactive_models
  end
end
