class Portal::LearnerActivityFeedback < ActiveRecord::Base
  belongs_to :portal_learner, class_name:  "Portal::Learner"
  belongs_to :activity_feedback, class_name: "Portal::OfferingActivityFeedback"
  self.table_name = :portal_learner_activity_feedbacks
  attr_accessible :has_been_reviewed,
    :score,
    :text_feedback,
    :activity_feedback,
    :activity_feedback_id,
    :portal_learner,
    :portal_learner_id

  def self._attribute_ids(*attributes)
    results = []
    for attribute in attributes do
      results.push(attribute.is_a?(Numeric) ? attribute : attribute.id)
    end
    return results
  end

  def self.for_learner_and_activity_feedback(learner,activity_feedback)
    learner_id, activity_feedback_id = self._attribute_ids(learner, activity_feedback)
    self.where({portal_learner_id: learner_id, activity_feedback_id: activity_feedback_id})
        .order("created_at desc") # most recent first
  end

  def self.open_feedback_for(learner, activity_feedback)
    results = self.for_learner_and_activity_feedback(learner, activity_feedback).where({has_been_reviewed: false})
      .limit(1)
      .first
    if results
      return results
    end
    l = learner.is_a?(Numeric) ? Portal::Learner.find(learner) : learner
    f = activity_feedback.is_a?(Numeric) ? Portal::OfferingActivityFeedback.find(activity_feedback) : activity_feedback
    return self.create({portal_learner:l, activity_feedback: f})
  end

  def self.update_feedback(learner, activity_feedback, attributes)
    open  = self.open_feedback_for(learner, activity_feedback)
    open.update_attributes(attributes)
  end


end
