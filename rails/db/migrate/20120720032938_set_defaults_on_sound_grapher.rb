class SetDefaultsOnSoundGrapher < ActiveRecord::Migration
  def up
    execute "UPDATE embeddable_sound_graphers SET display_mode='Waves' WHERE display_mode    IS NULL"
    execute "UPDATE embeddable_sound_graphers SET max_frequency=1000   WHERE max_frequency   IS NULL"
    execute "UPDATE embeddable_sound_graphers SET max_sample_time=30   WHERE max_sample_time IS NULL"
  end

  def down
  end
end
