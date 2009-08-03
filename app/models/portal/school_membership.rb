class Portal::SchoolMembership < ActiveRecord::Base
  set_table_name :portal_school_memberships
  
  acts_as_replicatable
  
  belongs_to :school, :class_name => "Portal::School", :foreign_key => "school_id"
  belongs_to :member, :polymorphic => true
end