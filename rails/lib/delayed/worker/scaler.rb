class JobManager
  def self.instance
    @@instance = self.new if @@instance.nil?
    return @@instance
  end

  def ps_tag
    Digest::MD5.hexdigest(Rails.root.to_s)[0..8]
  end

  def initialize
    @jobs = []
  end

  def exec_env
    { "RAILS_ENV" => Rails.env }
  end

  def workers
    # Synchronous read for jobs
    running = `ps`.split("\n").select do |line|
      line =~ /delayed_job start -i #{ps_tag}/ &&
      line =~ /#{ps_tag}/
    end
    running.size
  end

  def start
    cmd_args = "script/delayed_job start -i #{ps_tag}".split
    @jobs << IO.popen([exec_env] + cmd_args)
  end

  def stop
    cmd_args = "script/delayed_job stop -i #{ps_tag}".split
    @jobs << IO.popen([exec_env] + cmd_args)
  end

end

# Controls for spawning a background processor if one doesn't already exist
# whenever delayed jobs are created.
# 2021-06-14 NP: If you have any failed jobs, the worker will continue running.

module Delayed::Worker::Scaler
  def self.included(base)
    base.send :extend, ClassMethods
    base.class_eval do
      after_commit(on: :update, if: proc { |r| !r.failed_at.nil? }) do
        self.class.down
      end
      after_commit(on: :destroy, if: proc { |r| r.destroyed? || !r.failed_at.nil? }) do
        self.class.down
      end
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

    def down
      if jobs.count == 0 and workers > 0
        @@job_manager.stop
      end
      true
    end

    def workers
      @@job_manager.workers
    end

    def jobs
      Delayed::Job.where(failed_at: nil)
    end

  end
end
