class CreatePortalPermissionForms < ActiveRecord::Migration
  def change
    create_table :portal_permission_forms do |t|
      t.string :name
      t.string :url
      t.timestamps
    end
  end
end
