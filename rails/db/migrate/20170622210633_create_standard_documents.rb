class CreateStandardDocuments < ActiveRecord::Migration
  def change
    create_table :standard_documents do |t|
      t.string :uri
      t.string :jurisdiction
      t.string :title
      t.string :name

      t.timestamps
    end

    add_index :standard_documents, :name, :unique => true

  end

end
