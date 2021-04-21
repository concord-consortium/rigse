class SpitResearcherReportTypes < ActiveRecord::Migration
  class ExternalReport < ApplicationRecord
  end

  def up
    ExternalReport.where(report_type: 'researcher').update_all(report_type: 'researcher-learner')
  end

  def down
    ExternalReport.where(report_type: 'researcher-learner').update_all(report_type: 'researcher')
  end
end
