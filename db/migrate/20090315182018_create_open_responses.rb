class CreateOpenResponses < ActiveRecord::Migration
  def self.up
    create_table :open_responses do |t|
      t.integer     :user_id
      t.column      :uuid, :string, :limit => 36

      t.string      :name
      t.text        :description
      t.text        :prompt
      t.string      :default_response  

      t.timestamps
    end
  end

  def self.down
    drop_table :open_responses
  end
end
