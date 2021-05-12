class AddAuthorEmailToInvestigation < ActiveRecord::Migration[5.1]
  def up
    add_column :investigations, :author_email, :string
  end
  
  def down
    remove_column :investigations, :author_email
  end
end
