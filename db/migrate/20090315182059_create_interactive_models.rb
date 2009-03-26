class CreateInteractiveModels < ActiveRecord::Migration
  def self.up
    create_table :interactive_models do |t|
      t.timestamps
      t.string      :name
      t.text         :description
      t.integer     :user_id
      t.string      :uuid,         :limit => 36
      t.string      :content
    end
  end

  def self.down
    drop_table :interactive_models
  end
end
