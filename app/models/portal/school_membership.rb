class Portal::SchoolMembership < ActiveRecord::Base
  set_table_name :portal_school_memberships
  
  acts_as_replicatable
  
  belongs_to :school, :class_name => "Portal::School", :foreign_key => "school_id"
  belongs_to :member, :polymorphic => true
  belongs_to :teacher, :class_name => "Portal::Teacher", :foreign_key => "member_id", :conditions => "member_type='Portal::Teacher'"
end
