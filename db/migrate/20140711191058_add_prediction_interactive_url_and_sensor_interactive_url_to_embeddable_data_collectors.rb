class AddPredictionInteractiveUrlAndSensorInteractiveUrlToEmbeddableDataCollectors < ActiveRecord::Migration
  def self.up
    add_column :embeddable_data_collectors, :prediction_interactive_url, :string
    add_column :embeddable_data_collectors, :sensor_interactive_url, :string
  end

  def self.down
    remove_column :embeddable_data_collectors, :sensor_interactive_url
    remove_column :embeddable_data_collectors, :prediction_interactive_url
  end
end
