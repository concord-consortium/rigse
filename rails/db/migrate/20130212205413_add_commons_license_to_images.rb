class AddCommonsLicenseToImages < ActiveRecord::Migration
  def up
    add_column :images, :license_code, :string
  end

  def down
    remove_column :images, :license_code
  end
end
