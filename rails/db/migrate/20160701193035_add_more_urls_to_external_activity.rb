class AddMoreUrlsToExternalActivity < ActiveRecord::Migration
  def change
    add_column :external_activities, :author_url, :string
    add_column :external_activities, :print_url, :string
  end
end
