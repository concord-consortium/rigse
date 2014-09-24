class CreateEmbeddableIframes < ActiveRecord::Migration
  def change
    create_table :embeddable_iframes do |t|
      t.integer :user_id
      t.string  :uuid, :limit => 36
      t.string  :name
      t.string  :description
      t.integer :width
      t.integer :height
      t.string  :url
      t.string :external_id

      t.timestamps
    end
  end
end
