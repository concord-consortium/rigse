class ModifyExternalActivityUrls < ActiveRecord::Migration
  def up
    change_column :external_activities, :author_url, :text
    change_column :external_activities, :print_url, :text
  end

  def down
    change_column :external_activities, :author_url, :string
    change_column :external_activities, :print_url, :string
  end
end
