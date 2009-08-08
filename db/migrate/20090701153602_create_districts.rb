class CreateDistricts < ActiveRecord::Migration
  def self.up
    create_table :portal_districts do |t|

      t.string    :uuid, :limit => 36
      t.string    :name
      t.text      :description

      t.timestamps
    end
  end

  def self.down
    drop_table :portal_districts
  end
end
