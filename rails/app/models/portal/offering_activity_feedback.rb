class Portal::OfferingActivityFeedback < ApplicationRecord
  SCORE_AUTO   = "auto"
  SCORE_NONE   = "none"
  SCORE_MANUAL = "manual"
  SCORE_RUBRIC = "rubric"
  SCORE_TYPES = [SCORE_AUTO, SCORE_MANUAL, SCORE_RUBRIC, SCORE_NONE]

  self.table_name = :portal_offering_activity_feedbacks

  serialize :rubric, JSON

  belongs_to :portal_offering, class_name: "Portal::Offering"
  belongs_to :activity
  has_many   :learner_activity_feedbacks, class_name: "Portal::LearnerActivityFeedback", foreign_key: "activity_feedback_id"

  def self.for_offering_and_activity(offering, activity)
    self.where(portal_offering_id: offering.id, activity_id: activity.id).order('created_at desc').first
  end

  def self.create_for_offering_and_activity(offering, activity)
    self.create(portal_offering_id: offering.id, activity_id: activity.id)
  end

  def self.find_or_create_for_offering_and_activity(offering, activity)
    self.for_offering_and_activity(offering, activity) || self.create_for_offering_and_activity(offering, activity)
  end

  def rubric_url
    if portal_offering.runnable.respond_to? :rubric_url
      portal_offering.runnable.rubric_url
    else
      nil
    end
  end

  def set_feedback_options(opts)
    if opts.key? :score_type
      unless SCORE_TYPES.include? opts[:score_type]
        opts.delete :score_type
      end
    end
    self.update(opts)
  end

  def enable_score_feedback
    score_type != SCORE_NONE
  end
end
