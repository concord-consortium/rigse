class AddGseKeyToGradeSpanExpectation < ActiveRecord::Migration[5.1]
  def self.up
    add_column :grade_span_expectations, :gse_key, :string
  end

  def self.down
    remove_column :grade_span_expectations, :gse_key
  end
end
