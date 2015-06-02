class CreateExports < ActiveRecord::Migration
  def self.up
     create_table :exports do |t|
      t.integer :job_id
      t.datetime :job_finished_at
      t.string :file_path
      t.timestamps
    end
  end

  def self.down
    drop_table :exports
  end
end
