class CreateExternalReports < ActiveRecord::Migration
  def change
    create_table :external_reports do |t|
      t.string :url
      t.string :name
      t.string :launch_text
      t.references :client
      t.timestamps
    end
    add_index :external_reports, :client_id
  end
end
