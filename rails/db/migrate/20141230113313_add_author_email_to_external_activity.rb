class AddAuthorEmailToExternalActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :external_activities, :author_email, :string
  end
end
