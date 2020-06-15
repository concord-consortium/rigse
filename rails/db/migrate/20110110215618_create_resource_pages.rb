class CreateResourcePages < ActiveRecord::Migration
  def self.up
    create_table :resource_pages do |t|
      t.integer   :user_id
      t.string    :name
      t.text      :description
      t.string    :publication_status,    :default => 'draft'

      t.timestamps
    end
  end

  def self.down
    drop_table :resource_pages
  end
end
