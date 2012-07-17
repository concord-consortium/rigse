# This migration comes from smartgraphs_connector (originally 20120706181038)
class CreateSmartgraphsConnectorPersistences < ActiveRecord::Migration
  def change
    create_table :smartgraphs_connector_persistences do |t|
      t.integer     :learner_id
      t.text        :content,        :limit => (8.megabytes - 1)
      t.timestamps
    end

    add_index :smartgraphs_connector_persistences, :learner_id, :name => 'sg_connector_learner_idx'
  end
end
