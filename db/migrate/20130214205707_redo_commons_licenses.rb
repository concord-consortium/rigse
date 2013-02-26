# Somehow the old migration was edited, and recommitted.
# luckily this table contains non-volitile data with natural keys.
# rebuilding it shouldn't cause any trouble.  February 14, 2013 (NP)
class RedoCommonsLicenses < ActiveRecord::Migration
  def up
    drop_table :commons_licenses
      create_table :commons_licenses, :id => false do |t|
      t.string   :code, :uniqueness => true, :null => false, :primary_key => true
      t.string   :name, :uniqueness => true, :null => false
      t.text     :description
      t.string   :deed
      t.string   :legal
      t.string   :image
      t.integer  :number
      t.timestamps
    end
    add_index  :commons_licenses, [:code]
  end

  # old table definition...
  def down
    drop_table :commons_licenses
    create_table :commons_licenses, :id => false do |t|
      t.string   :code, :uniqueness => true, :null => false, :primary_key => true
      t.string   :name, :uniqueness => true, :null => false
      t.text     :description
      t.string   :deed
      t.string   :legal
      t.string   :image
      t.timestamps
    end
    execute "ALTER TABLE commons_licenses ADD PRIMARY KEY (code);"
  end
end
