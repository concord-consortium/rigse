class Portal::LearnerActivityFeedback < ActiveRecord::Base
  belongs_to :portal_learner, class_name: "Portal::Learner"
  belongs_to :activity_feedback, class_name: "Portal::OfferingActivityFeedback"
  self.table_name = :portal_learner_activity_feedbacks

  serialize :rubric_feedback, JSON

  default_scope { order('created_at DESC') }

  def self.for_learner_and_activity_feedback(learner_id, activity_feedback_id)
    self.where({portal_learner_id: learner_id, activity_feedback_id: activity_feedback_id})
        .order("created_at desc") # most recent first
  end

  def self.open_feedback_for(learner_id, activity_feedback_id)
    self.for_learner_and_activity_feedback(learner_id, activity_feedback_id).limit(1).first ||
    self.create({portal_learner_id: learner_id, activity_feedback_id: activity_feedback_id})
  end

  def self.update_feedback(learner_id, activity_feedback_id, attributes)
    open  = self.open_feedback_for(learner_id, activity_feedback_id)
    open.update_attributes(attributes)
  end
end
