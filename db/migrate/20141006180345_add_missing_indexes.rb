class AddMissingIndexes < ActiveRecord::Migration
  def up
    add_index :investigations, [:is_featured, :publication_status], :name => 'featured_public'
    add_index :investigations, :publication_status, :name =>'pub_status'
    add_index :activities, [:is_featured, :publication_status], :name => 'featured_public'
    add_index :activities, :publication_status, :name =>'pub_status'
    add_index :external_activities, [:is_featured, :publication_status], :name => 'featured_public'
    add_index :external_activities, :publication_status, :name =>'pub_status'
  end

  def down
    remove_index :investigations, :name => 'featured_public'
    remove_index :investigations, :name => 'pub_status'
    remove_index :activities, :name => 'featured_public'
    remove_index :activities, :name => 'pub_status'
    remove_index :external_activities, :name => 'featured_public'
    remove_index :external_activities, :name => 'pub_status'
  end
end
