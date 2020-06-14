class CreateOfferings < ActiveRecord::Migration
  def self.up
    create_table :portal_offerings do |t|

      t.string    :uuid, :limit => 36
      t.string    :name
      t.text      :description
      
      t.string    :status
      
      t.integer   :clazz_id
      t.integer   :runnable_id
      t.string    :runnable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :portal_offerings
  end
end
