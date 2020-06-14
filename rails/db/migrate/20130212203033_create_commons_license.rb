class CreateCommonsLicense < ActiveRecord::Migration
  def up
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

  def down
    drop_table :commons_licenses
  end

end
