class CreateStandardDocuments < ActiveRecord::Migration
  def change
    create_table :standard_documents do |t|
      t.string :title
      t.string :uri

      t.timestamps
    end
  end
end
