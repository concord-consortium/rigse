class CreateImports < ActiveRecord::Migration
  def up
    create_table :imports, :force => true do |t|
      t.integer    :job_id
      t.datetime   :job_finished_at
      t.integer    :import_type
      t.text       :duplicate_data
      t.integer    :progress
      t.integer    :total_imports
      t.integer    :user_id
      t.text       :upload_data , :limit => 4294967295
      t.timestamps
    end
  end

  def down
    drop_table :imports
  end
end
