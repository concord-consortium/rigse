class RemoveIsTemplateCollumns < ActiveRecord::Migration
  def up
    remove_column :investigations, :is_template
    remove_column :activities, :is_template
  end

  def down
    add_column :investigations, :is_template, :boolean, :default => true
    add_column :activities,  :is_template, :boolean, :default => true
  end
end
