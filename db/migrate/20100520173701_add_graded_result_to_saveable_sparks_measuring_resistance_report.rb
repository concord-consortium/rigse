class AddGradedResultToSaveableSparksMeasuringResistanceReport < ActiveRecord::Migration
  def self.up
    add_column :saveable_sparks_measuring_resistance_reports, :graded_result, :text
  end

  def self.down
    remove_column :saveable_sparks_measuring_resistance_reports, :graded_result
  end
end
