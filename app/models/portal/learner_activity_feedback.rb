class Portal::LearnerActivityFeedback < ActiveRecord::Base
  belongs_to :portal_learner, class_name: "Portal::Learner"
  belongs_to :activity_feedback, class_name: "Portal::OfferingActivityFeedback"
  self.table_name = :portal_learner_activity_feedbacks
  attr_accessible :has_been_reviewed,
    :score,
    :text_feedback,
    :rubric_feedback,
    :activity_feedback,
    :activity_feedback_id,
    :portal_learner,
    :portal_learner_id

  serialize :rubric_feedback, JSON

  default_scope :order => 'created_at DESC'

  def self._attribute_ids(*attributes)
    results = []
    for attribute in attributes do
      case attribute
      when Numeric, String
        results.push(attribute)
      else
        results.push(attribute.id)
      end
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

    case learner
    when Numeric, String
      l = Portal::Learner.find(learner)
    else
      l = learner
    end

    case activity_feedback
    when Numeric, String
      f = Portal::OfferingActivityFeedback.find(activity_feedback)
    else
      f = activity_feedback
    end

    return self.create({portal_learner:l, activity_feedback: f})
  end

  def self.update_feedback(learner, activity_feedback, attributes)
    open  = self.open_feedback_for(learner, activity_feedback)
    open.update_attributes(attributes)
  end


end
