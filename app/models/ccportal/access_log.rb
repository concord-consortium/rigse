class Ccportal::AccessLog < Ccportal::Ccportal
  self.table_name = :portal_access_log
  set_primary_key :access_log_id

  belongs_to :member, :foreign_key => :member_id
  belongs_to :school, :foreign_key => :school_id

end
