class DropSparksTables < ActiveRecord::Migration[6.1]
  def up
    drop_table :saveable_sparks_measuring_resistance
    drop_table :saveable_sparks_measuring_resistance_reports
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
