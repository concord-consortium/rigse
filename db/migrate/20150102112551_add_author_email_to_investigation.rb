class AddAuthorEmailToInvestigation < ActiveRecord::Migration
  def change
    add_column :investigations, :author_email, :string
  end
end
