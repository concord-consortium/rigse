class ExternalActivityReport < ApplicationRecord
  belongs_to :external_activity
  belongs_to :external_report
end
