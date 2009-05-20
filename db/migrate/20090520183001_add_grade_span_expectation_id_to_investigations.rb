class AddGradeSpanExpectationIdToInvestigations < ActiveRecord::Migration
  def self.up
    add_column :investigations, :grade_span_expectation_id, :integer
  end

  def self.down
    remove_column :investigations, :grade_span_expectation_id
  end
end
