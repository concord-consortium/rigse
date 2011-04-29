class CreateSaveableMeasuringResistance < ActiveRecord::Migration
  def self.up
    create_table :saveable_sparks_measuring_resistance do |t|
      t.integer     :learner_id
      t.timestamps
    end
    create_table :saveable_sparks_measuring_resistance_reports do |t|
      t.integer     :measuring_resistance_id
      t.integer     :position
      t.text        :content
      t.timestamps
    end
  end

  def self.down
    drop_table :saveable_sparks_measuring_resistance_reports
    drop_table :saveable_sparks_measuring_resistance
  end
end
