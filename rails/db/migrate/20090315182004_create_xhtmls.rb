class CreateXhtmls < ActiveRecord::Migration
  def self.up
    create_table :xhtmls do |t|
      t.integer     :user_id
      t.column      :uuid, :string, :limit => 36

      t.string      :name
      t.text        :description
      t.text        :content
      
      t.timestamps
    end
  end

  def self.down
    drop_table :xhtmls
  end
end
