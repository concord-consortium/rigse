class RedoExpectationToGradeSpanExp < ActiveRecord::Migration
  def self.up
    drop_table   :expectation_stems_grade_span_expectations
    create_table :expectation_stems_grade_span_expectations, :id => false do |t|
      t.integer  :grade_span_expectation_id
      t.integer  :expectation_stem_id
    end
  end

  def self.down
    drop_table :expectation_stems_grade_span_expectations
    
    create_table :expectation_stems_grade_span_expectations  do |t|
      t.integer  :grade_span_expectation_id
      t.integer  :expectation_stem_id
    end
  end
end
