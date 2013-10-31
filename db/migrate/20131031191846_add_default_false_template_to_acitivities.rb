class AddDefaultFalseTemplateToAcitivities < ActiveRecord::Migration
  def change
    change_column :activities, :is_template, :boolean, :default => false
  end
end
