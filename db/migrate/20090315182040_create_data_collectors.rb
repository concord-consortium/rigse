class CreateDataCollectors < ActiveRecord::Migration
  def self.up
    create_table :data_collectors do |t|
      t.string      :name
      t.string      :description
      t.integer     :user_id
      t.column      :uuid, :string, :limit => 36
      t.string      :content
    end
  end

  def self.down
    drop_table :data_collectors
  end
end
