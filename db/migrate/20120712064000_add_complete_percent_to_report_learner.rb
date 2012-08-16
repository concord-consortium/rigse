class AddCompletePercentToReportLearner < ActiveRecord::Migration

  # faux model for successful migration
  class Report::Learner < ActiveRecord::Base
    set_table_name :report_learners
    belongs_to   :learner, :class_name => "Portal::Learner", :foreign_key => "learner_id"
  end

  def self.up
    add_column :report_learners, :complete_percent, :float
    
    execute "UPDATE report_learners SET complete_percent = ((IFNULL(num_answered, 0) * 100) / num_answerables)"
  end

  def self.down
    remove_column :report_learners, :complete_percent
  end
end
