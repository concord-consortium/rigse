class AddAuthorEmailToExternalActivity < ActiveRecord::Migration
  def change
    add_column :external_activities, :author_email, :string
  end
end
