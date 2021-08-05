class AddDefaultFalseTemplateToAcitivities < ActiveRecord::Migration[5.1]
  def up
    change_column :activities, :is_template, :boolean, :default => false
  end
  def down
    change_column :activities, :is_template, :boolean
  end
end
