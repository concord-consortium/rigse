class RedoGseTables < ActiveRecord::Migration
  def self.up
    
    drop_table :expectation_stems_grade_span_expectations
    
    remove_column :expectations, :description
    remove_column :expectations, :ordinal
    
    add_column :expectations, :grade_span_expectation_id, :integer
    
    rename_column :expectation_stems, :stem, :description
    
    create_table :expectation_indicators do |t|
      t.integer :expectation_id
      t.string  :description
      t.string  :ordinal
      t.column :uuid, :string, :limit => 36
      t.timestamps
    end

  end

  def self.down
    create_table :expectation_stems_grade_span_expectations, :id => false do |t|
      t.integer  :grade_span_expectation_id
      t.integer  :expectation_stem_id
    end
    
    add_column :expectations, :ordinal, :string 
    add_column :expectations, :description, :string
     
    remove_column :expectations, :grade_span_expectation_id
        
    rename_column :expectation_stems, :description, :stem
    
    drop_table :expectation_indicators

  end
end
