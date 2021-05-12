class MoveExternalReports < ActiveRecord::Migration[5.1]

  class ExternalReport < ApplicationRecord
  end

  class ExternalActivityReport < ApplicationRecord
    belongs_to :external_activity
    belongs_to :external_report
  end

  class  ExternalActivity  < ApplicationRecord
    belongs_to :external_report
    has_many :external_activity_reports
    has_many :external_reports, through: :external_activity_reports
  end


  def up_activity(a)
    if(a.external_report)
      a.external_reports=[a.external_report]
      a.save
      putc "."
    end
  end

  def down_activity(a)
    if(a.external_reports.length > 0)
      report = a.external_reports[0]
      a.update_attribute(:external_report_id, report.id)
      putc "."
    end
  end

  def up
    ExternalActivity.find_in_batches do |batch|
      batch.each { |a| up_activity(a) }
    end
    remove_column :external_activities, :external_report_id
    puts
  end

  def down
    add_column :external_activities, :external_report_id,  :integer
    ExternalActivity.find_in_batches do |batch|
      batch.each { |a| down_activity(a) }
    end
    puts
  end
end
