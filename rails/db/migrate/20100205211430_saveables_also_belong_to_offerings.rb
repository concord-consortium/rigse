class SaveablesAlsoBelongToOfferings < ActiveRecord::Migration
  def self.up
    add_column :saveable_open_responses,              :offering_id, :integer 
    add_column :saveable_multiple_choices,            :offering_id, :integer 
    add_column :saveable_sparks_measuring_resistance, :offering_id, :integer 

    add_index  :saveable_open_responses,              :offering_id
    add_index  :saveable_open_responses,              :learner_id
    add_index  :saveable_multiple_choices,            :offering_id 
    add_index  :saveable_multiple_choices,            :learner_id
    add_index  :saveable_sparks_measuring_resistance, :offering_id 
    add_index  :saveable_sparks_measuring_resistance, :learner_id
  end

  def self.down
    remove_index  :saveable_open_responses,              :offering_id
    remove_index  :saveable_open_responses,              :learner_id
    remove_index  :saveable_multiple_choices,            :offering_id 
    remove_index  :saveable_multiple_choices,            :learner_id
    remove_index  :saveable_sparks_measuring_resistance, :offering_id 
    remove_index  :saveable_sparks_measuring_resistance, :learner_id

    remove_column :saveable_open_responses,              :offering_id
    remove_column :saveable_multiple_choices,            :offering_id
    remove_column :saveable_sparks_measuring_resistance, :offering_id 
  end
end
