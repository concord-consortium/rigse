class AddDisplayModeToEmbeddableSoundGraphers < ActiveRecord::Migration
  def self.up
    add_column :embeddable_sound_graphers, :max_frequency, :string
    add_column :embeddable_sound_graphers, :max_sample_time, :string
    add_column :embeddable_sound_graphers, :display_mode, :string
  end

  def self.down
    remove_column :embeddable_sound_graphers, :display_mode
    remove_column :embeddable_sound_graphers, :max_sample_time
    remove_column :embeddable_sound_graphers, :max_frequency
  end
end
