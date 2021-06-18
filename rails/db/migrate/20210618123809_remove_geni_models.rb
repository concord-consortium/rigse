class RemoveGeniModels < ActiveRecord::Migration[6.1]
  def up
    drop_table :geniverse_activities
    drop_table :geniverse_articles
    drop_table :geniverse_cases
    drop_table :geniverse_dragons
    drop_table :geniverse_help_messages
    drop_table :geniverse_unlockables
    drop_table :geniverse_users
  end

  def down
    # no going back!
    raise ActiveRecord::IrreversibleMigration
  end
end
