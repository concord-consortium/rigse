class CreateAdminAuthoringSites < ActiveRecord::Migration
  def change
    create_table :authoring_sites do |t|
      t.string :name
      t.string :url

      t.timestamps
    end
  end
end
