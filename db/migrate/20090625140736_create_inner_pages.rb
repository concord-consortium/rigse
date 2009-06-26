class CreateInnerPages < ActiveRecord::Migration
  def self.up
    create_table :inner_pages do |t|
      t.integer   :user_id
      t.string    :uuid,        :limit => 36
      t.string    :name
      t.text      :description
      t.timestamps
    end
  end

  def self.down
    drop_table :inner_pages
  end
end
