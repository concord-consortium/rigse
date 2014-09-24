class CreateSaveableExternalLinks < ActiveRecord::Migration
  def change
    create_table :saveable_external_links do |t|
      t.integer :embeddable_id
      t.string  :embeddable_type
      t.integer :learner_id
      t.integer :offering_id
      t.integer :response_count

      t.timestamps
    end
  end
end
