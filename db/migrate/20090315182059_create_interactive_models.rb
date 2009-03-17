class CreateInteractiveModels < ActiveRecord::Migration
  def self.up
    create_table :interactive_models do |t|
      t.string      :prompt
      t.string      :response
      t.timestamps
    end
  end

  def self.down
    drop_table :interactive_models
  end
end
