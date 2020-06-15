class CreateImportUserSchoolMappings < ActiveRecord::Migration
  def up
    create_table :import_user_school_mappings do |t|
      t.integer :school_id
      t.string  :import_school_url
    end
  end
  
  def down
    drop_table :import_user_school_mappings
  end
end
