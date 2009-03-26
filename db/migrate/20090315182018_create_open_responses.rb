class CreateOpenResponses < ActiveRecord::Migration
  def self.up
    create_table :open_responses do |t|
      t.timestamps
      t.string      :name
      t.text         :description
      t.integer     :user_id
      t.column      :uuid, :string, :limit => 36
      t.text        :prompt
      t.string      :default_response  
    end
  end

  def self.down
    drop_table :open_responses
  end
end
