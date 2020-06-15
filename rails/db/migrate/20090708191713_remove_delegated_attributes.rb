class RemoveDelegatedAttributes < ActiveRecord::Migration
  def self.up
    remove_column :portal_teachers, :name
    remove_column :portal_teachers, :description
    remove_column :portal_students, :name
    remove_column :portal_students, :description
    remove_column :portal_offerings, :name
    remove_column :portal_offerings, :description
    remove_column :portal_learners, :name
    remove_column :portal_learners, :description
  end

  def self.down
    add_column :portal_teachers, :name, :string
    add_column :portal_teachers, :description, :text
    add_column :portal_students, :name, :string
    add_column :portal_students, :description, :text
    add_column :portal_offerings, :name, :string
    add_column :portal_offerings, :description, :text
    add_column :portal_learners, :name, :string
    add_column :portal_learners, :description, :text
  end
end
