class ChangeFeedbackScoreDefaultValue < ActiveRecord::Migration
  def up
    change_column_default(:portal_learner_activity_feedbacks, :score, 0)
  end

  def down
    change_column_default(:portal_learner_activity_feedbacks, :score, 10)
  end
end
