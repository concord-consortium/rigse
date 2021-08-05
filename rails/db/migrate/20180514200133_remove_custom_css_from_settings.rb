class RemoveCustomCssFromSettings < ActiveRecord::Migration[5.1]
  def up
    remove_column :admin_settings, :custom_css
  end

  def down
    add_column :admin_settings, :custom_css, :text
  end
end
