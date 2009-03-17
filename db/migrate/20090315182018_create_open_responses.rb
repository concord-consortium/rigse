class CreateOpenResponses < ActiveRecord::Migration
  def self.up
    create_table :open_responses do |t|
      t.string      :prompt
      t.string      :options
      t.timestamps
    end
  end

  def self.down
    drop_table :open_responses
  end
end
