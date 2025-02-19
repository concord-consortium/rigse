class JobManager

  def ps_tag
    Digest::MD5.hexdigest(Rails.root.to_s)[0..8]
  end

  def exec_env
    { "RAILS_ENV" => Rails.env }
  end

  def workers
    # Synchronous read for jobs
    all_jobs = `ps aux`.split("\n")
    running = all_jobs.select do |line|
      line =~ /delayed_job/ && line =~ /#{ps_tag}/
    end
    running.size
  end

  def start
    cmd_args = "script/delayed_job start -i #{ps_tag}".split
    IO.popen([exec_env] + cmd_args)
  end

  def stop
    cmd_args = "script/delayed_job stop -i #{ps_tag}".split
    IO.popen([exec_env] + cmd_args)
  end
end

# Controls for spawning a background processor if one doesn't already exist
# whenever delayed jobs are created.
# 2021-06-14 NP: This worker will continue running. When we switch to
# ActiveJob, we can use the built-in in-memory job queuing implementation

module Delayed::Worker::Scaler
  def self.included(base)
    base.send :extend, ClassMethods
    base.class_eval do
      after_commit(on: :create) do
        self.class.up
      end
    end
  end

  module ClassMethods
    @@job_manager = JobManager.new
    @@ps_tag = nil
    @@last_start = 1.day.ago
    def up
      if workers == 0 && ((Time.now - @@last_start) > 30)
        @@last_start = Time.now
        @@job_manager.start
      end
      true
    end

    def workers
      @@job_manager.workers
    end

    def jobs
      # TODO: After migrating from DelayedJob on the backend (e.g., to Sidekiq), revisit
      # this method and change to use an appropriate query.
      Delayed::Job.where(failed_at: nil)
    end

  end
end
