class CreateExternalReports < ActiveRecord::Migration[5.1]
  def change
    create_table :external_reports do |t|
      t.string :url
      t.string :name
      t.string :launch_text
      t.references :client
      t.timestamps
    end
  end
end
