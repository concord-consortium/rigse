class AddCompletePercentToReportLearner < ActiveRecord::Migration

  # faux model for successful migration
  class Report::Learner < ActiveRecord::Base
    set_table_name :report_learners
  end

  def self.up
    add_column :report_learners, :complete_percent, :double
    Report::Learner.reset_column_information
    learners = Report::Learner.all
    learners.each do |learner|
      report_util = Report::Util.new(learner, false, true)
      learner.complete_percent = report_util.complete_percent(learner)
      learner.save!
    end
  end

  def self.down
    remove_column :report_learners, :complete_percent
  end
end
