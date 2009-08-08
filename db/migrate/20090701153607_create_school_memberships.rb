class CreateSchoolMemberships < ActiveRecord::Migration
  def self.up
    create_table :portal_school_memberships do |t|

      t.string    :uuid, :limit => 36
      t.string    :name
      t.text      :description
      
      t.datetime  :start_time
      t.datetime  :end_time
      
      t.references :member, :polymorphic => true
      t.references :school

      t.timestamps
    end
  end

  def self.down
    drop_table :portal_school_memberships
  end
end
