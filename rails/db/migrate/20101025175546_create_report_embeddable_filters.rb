class CreateReportEmbeddableFilters < ActiveRecord::Migration[5.1]
  def self.up
    create_table :report_embeddable_filters do |t|
      t.integer :offering_id
      t.text    :embeddables
      
      t.timestamps
    end
  end

  def self.down
    drop_table :report_embeddable_filters
  end
end
