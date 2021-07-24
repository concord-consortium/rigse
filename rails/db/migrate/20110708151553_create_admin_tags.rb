class CreateAdminTags < ActiveRecord::Migration[5.1]
  def self.up
    create_table :admin_tags do |t|
      t.string :scope
      t.string :tag

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_tags
  end
end
