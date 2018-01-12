class Portal::OfferingActivityFeedback < ActiveRecord::Base
  SCORE_AUTO   = "auto"
  SCORE_NONE   = "none"
  SCORE_MANUAL = "manual"
  SCORE_TYPES = [SCORE_AUTO, SCORE_MANUAL, SCORE_NONE]

  self.table_name = :portal_offering_activity_feedbacks
  attr_accessible :enable_text_feedback,
    :max_score,
    :score_type,
    :portal_offering,
    :portal_offering_id,
    :activity,
    :activity_id

  belongs_to :portal_offering, class_name: "Portal::Offering"
  belongs_to :activity
  has_many   :learner_activity_feedbacks, class_name: "Portal::LearnerActivityFeedback", foreign_key: "activity_feedback_id"

  def self.for_offering_and_activity(offering, activity)
    params = { portal_offering_id: offering.id, activity_id: activity.id }
    found  = self.where(params).order('created_at desc').first
    unless(found)
      found= self.create(params)
    end
    return found
  end

  def set_feedback_options(opts)
    if opts.key? :score_type
      unless SCORE_TYPES.include? opts[:score_type]
        opts.delete :score_type
      end
    end
    self.update_attributes(opts)
  end

end
