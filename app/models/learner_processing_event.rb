class LearnerProcessingEvent < ActiveRecord::Base

  belongs_to :learner, class_name: Portal::Learner

  attr_accessible :duration, :elapsed_seconds, :lara_end, :lara_start,
    :login, :portal_end, :portal_start, :teacher, :url


  # Humanize duration seconds, similar to ActiveSupport's distance_of_time_in_words
  def self.humanize(secs)
    if secs.nil?
      return "N/A"
    end
    [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i} #{name}"
      end
    }.compact.reverse.join(' ')
  end


  def self.build_proccesing_event(learner, lara_start, lara_end, portal_start, answers_length)
    record = self.new()
    record.learner         = learner
    record.portal_end      = Time.now

    record.portal_start    = portal_start || record.portal_end
    record.lara_end        = lara_end     || record.portal_start
    record.lara_start      = lara_start

    if record.lara_start
      record.lara_duration = record.lara_end   - record.lara_start
    else
      record.lara_duration = 0
    end

    record.portal_duration = record.portal_end - record.portal_start

    if record.lara_start
      record.elapsed_seconds = record.portal_end - record.lara_start
    else
      record.elapsed_seconds = record.portal_end - record.lara_end
    end

    record.duration        = humanize(record.elapsed_seconds)
    record.login           = (record.learner.student.user.login           rescue 'unknown login').to_s
    record.teacher         = (record.learner.offering.clazz.teacher.name  rescue 'unknown teacher').to_s
    record.url             = (record.learner.offering.runnable.url        rescue 'unknown runnable url').to_s
    # answers_length is not stored in the database because it is likely that we'll stop storing
    # this model completely and just log the data
    record.log_event(answers_length)
    return record
  end

  def log_event(answers_length)
    # this is structured so CloudWatch can parse it
    info = "#{elapsed_seconds} #{portal_duration} #{lara_duration} #{answers_length} #{learner_id} #{url}"
    if lara_start
      logger.info "LearnerProcessingEventWithLaraStart #{info}"
    else
      logger.info "LearnerProcessingEvent #{info}"
    end
  end

  def self.avg_delay(hours=2)
    self.where("updated_at > ?", hours.hours.ago).average(:elapsed_seconds)
  end

  def self.max_delay(hours=2)
    self.where("updated_at > ?", hours.hours.ago).maximum(:elapsed_seconds)
  end

  # only include records that have a valid lara_start
  def self.histogram(hours=12)
    hours.times.to_a.reverse.map do |h|
      start_time = (h+1).hours.ago
      end_time   = h.hours.ago
      range = self.where("lara_start IS NOT NULL and updated_at  > ? and updated_at < ?", start_time, end_time)
      {
        total: range.average(:elapsed_seconds).to_i,
        lara: range.average(:lara_duration).to_i,
        portal: range.average(:portal_duration).to_i
      }
    end
  end

  def self.human_max(houts)
    humanize(max_delay(hours))
  end
  def self.human_avg(hours)
    humanize(avg_delay(hours))
  end
end
