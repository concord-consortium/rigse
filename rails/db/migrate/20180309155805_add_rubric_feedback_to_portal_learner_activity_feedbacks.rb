class AddRubricFeedbackToPortalLearnerActivityFeedbacks < ActiveRecord::Migration[5.1]
  def change
    add_column :portal_learner_activity_feedbacks, :rubric_feedback, :text
  end
end
