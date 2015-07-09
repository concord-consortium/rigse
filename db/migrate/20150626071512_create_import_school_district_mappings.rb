class CreateImportSchoolDistrictMappings < ActiveRecord::Migration
  def up
    create_table :import_school_district_mappings do |t|
      t.integer :district_id
      t.string  :import_district_uuid
    end
  end

  def down
    drop_table :import_school_district_mappings
  end
end
