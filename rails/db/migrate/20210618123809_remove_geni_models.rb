class RemoveGeniModels < ActiveRecord::Migration[6.1]
  def up
    drop_table :geniverse_activities, :if_exists => true
    drop_table :geniverse_articles, :if_exists => true
    drop_table :geniverse_cases, :if_exists => true
    drop_table :geniverse_dragons, :if_exists => true
    drop_table :geniverse_help_messages, :if_exists => true
    drop_table :geniverse_unlockables, :if_exists => true
    drop_table :geniverse_users, :if_exists => true
  end

  def down
    # no going back!
    raise ActiveRecord::IrreversibleMigration
  end
end
