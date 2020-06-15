class UpdateReportLearnersNumSubmitted < ActiveRecord::Migration
  class Report::Learner < ActiveRecord::Base
    self.table_name = "report_learners"
  end

  def up
    Report::Learner.reset_column_information
    # Of course that makes sense only for old activities that do not have any required questions.
    # Newer activities with required questions and submitted / unsubmitted answers require more
    # complex reprocessing anyway.
    Report::Learner.update_all('num_submitted = num_answered', 'num_submitted IS NULL')
  end

  def down
    # Down migration doesn't make any sense here. Once num_submitted is updated, we can't
    # distinguish whether it was updated by the script above or by reprocessing of the
    # student's data.
  end
end
