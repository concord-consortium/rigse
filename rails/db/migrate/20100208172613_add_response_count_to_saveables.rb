class AddResponseCountToSaveables < ActiveRecord::Migration
  def self.up
    add_column :saveable_open_responses,              :response_count, :integer, :default => 0
    add_column :saveable_multiple_choices,            :response_count, :integer, :default => 0
    
    # update new counter_cache attributes ...
    [Saveable::OpenResponse, Saveable::MultipleChoice].each do |klass|
      klass.reset_column_information
      klass.find(:all, :include => :answers).each do |saveable| 
        klass.update_counters(saveable.id, :response_count => saveable.answers.length)
      end
    end
  end

  def self.down
    remove_column :saveable_open_responses,           :response_count
    remove_column :saveable_multiple_choices,         :response_count
  end
end
