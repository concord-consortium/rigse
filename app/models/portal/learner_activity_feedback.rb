class Portal::LearnerActivityFeedback < ActiveRecord::Base
  belongs_to :portal_learner, class_name:  "Portal::Learner"
  belongs_to :activity_feedback, class_name: "Portal::OfferingActivityFeedback"
  attr_accessible :has_been_reviewed,
    :score,
    :text_feedback,
    :activity_feedback,
    :activity_feedback_id,
    :portal_learner,
    :portal_learner_id

  def self.for_learner_and_activity_feedback(learner,activity_feedback)
    self.where({portal_learner_id: learner.id, activity_feedback_id: activity_feedback.id}).order(created_at: :desc)
  end
end
