class LearnerProcessingEvent < ActiveRecord::Base

  belongs_to :learner, class_name: Portal::Learner

  attr_accessible :duration, :elapsed_seconds, :lara_end, :lara_start, :login, :portal_end, :portal_start, :teacher, :url


  # Humanize duration seconds, similar to ActiveSupport's distance_of_time_in_words
  def self.humanize(secs)
    [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i} #{name}"
      end
    }.compact.reverse.join(' ')
  end

  def self.build_proccesing_event(learner, lara_start, lara_end, portal_start)
    record = self.new()
    record.learner         = learner
    record.portal_end      = Time.now

    record.portal_start    = portal_start || record.portal_end
    record.lara_end        = lara_end     || record.portal_start
    record.lara_start      = lara_start   || record.lara_end

    record.elapsed_seconds = record.portal_end - record.lara_start
    record.duration        = humanize(record.elapsed_seconds)
    record.login           = (record.learner.student.user.login           rescue 'unknown login').to_s
    record.teacher         = (record.learner.offering.clazz.teacher.name  rescue 'unknown teacher').to_s
    record.url             = (record.learner.offering.runnable.url        rescue 'unknown runnable url').to_s
    return record
  end

  def self.avg_delay(hours=2)
    self.where("updated_at > ?", hours.hours.ago).average(:elapsed_seconds)
  end

  def self.max_delay(hours=2)
    self.where("updated_at > ?", hours.hours.ago).maximum(:elapsed_seconds)
  end

  def self.human_max
    humanize(max_delay)
  end
  def self.human_avg
    humanize(avg_delay)
  end
end
