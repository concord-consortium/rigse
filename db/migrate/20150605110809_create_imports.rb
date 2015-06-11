class CreateImports < ActiveRecord::Migration
  def up
    create_table :imports do |t|
      t.integer    :job_id
      t.datetime   :job_finished_at
      t.integer    :import_type
      t.text       :duplicate_data
      t.integer    :progress
      t.integer    :total_imports
      t.timestamps
    end
  end

  def down
    drop_table :imports
  end
end
