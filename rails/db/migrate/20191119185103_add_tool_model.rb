class AddToolModel < ActiveRecord::Migration[5.1]
  def change
    create_table :tools do |t|
      t.string :name
      t.string :source_type
      t.text :tool_id
    end
  end
end
