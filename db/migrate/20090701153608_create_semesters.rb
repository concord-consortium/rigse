class CreateSemesters < ActiveRecord::Migration
  def self.up
    create_table :portal_semesters do |t|

      t.string    :uuid, :limit => 36
      t.string    :name
      t.text      :description
      
      t.integer   :school_id
      
      t.datetime  :start_time
      t.datetime  :end_time

      t.timestamps
    end
  end

  def self.down
    drop_table :portal_semesters
  end
end
