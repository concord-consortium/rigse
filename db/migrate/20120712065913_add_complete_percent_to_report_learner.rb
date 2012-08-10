class AddCompletePercentToReportLearner < ActiveRecord::Migration

  # faux model for successful migration
  class Report::Learner < ActiveRecord::Base
    set_table_name :report_learners
    belongs_to   :learner, :class_name => "Portal::Learner", :foreign_key => "learner_id"
  end

  def self.up
    add_column :report_learners, :complete_percent, :float
    Report::Learner.reset_column_information
    report_learners = Report::Learner.all
    report_learners.each do |report_learner|
      portal_learner = report_learner.learner
      report_util = Report::Util.new(portal_learner, false, true)
      report_learner.complete_percent = report_util.complete_percent(portal_learner)
      report_learner.save!
    end
  end

  def self.down
    remove_column :report_learners, :complete_percent
  end
end
