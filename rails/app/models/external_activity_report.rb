class ExternalActivityReport < ActiveRecord::Base

  attr_accessible :external_activity_id, :external_report_id

  belongs_to :external_activity
  belongs_to :external_report
end
