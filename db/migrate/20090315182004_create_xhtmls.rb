class CreateXhtmls < ActiveRecord::Migration
  def self.up
    create_table :xhtmls do |t|
      t.string      :name
      t.string      :contents
      t.timestamps
    end
  end

  def self.down
    drop_table :xhtmls
  end
end
