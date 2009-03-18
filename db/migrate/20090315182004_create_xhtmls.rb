class CreateXhtmls < ActiveRecord::Migration
  def self.up
    create_table :xhtmls do |t|
      t.timestamps
      t.string      :name
      t.string      :description
      t.integer     :user_id
      t.column      :uuid, :string, :limit => 36
      t.string      :prompt
      t.string      :content
    end
  end

  def self.down
    drop_table :xhtmls
  end
end
