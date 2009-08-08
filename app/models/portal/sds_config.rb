class Portal::SdsConfig < ActiveRecord::Base
  set_table_name :portal_sds_configs
  
  belongs_to :configurable, :polymorphic => true
end
