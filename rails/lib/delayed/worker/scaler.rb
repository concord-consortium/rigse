require 'rush'

# Controls for spawning a background processor if one doesn't already exist
# whenever delayed jobs are created. It will also tear the processor down
# after all the jobs in the queue have been taken care of.

# Based off the 'workless' gem: https://github.com/lostboy/workless

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
    @@ps_tag = nil
    @@last_start = 1.day.ago
    def up
      if workers == 0 && ((Time.now - @@last_start) > 30)
        @@last_start = Time.now
        Rush::Box.new[Rails.root].bash("script/delayed_job start -i #{process_tag}", :background => true, :env => {:RAILS_ENV => Rails.env})
      end
      true
    end

    def down
      if jobs.count == 0 and workers > 0
        Rush::Box.new[Rails.root].bash("script/delayed_job stop -i #{process_tag}", :background => true, :env => {:RAILS_ENV => Rails.env})
      end
      true
    end

    def workers
      Rush::Box.new.processes.filter(:cmdline => /delayed_job start -i #{process_tag}|delayed_job.#{process_tag}/).size
    end

    def jobs
      Delayed::Job.where(failed_at: nil)
    end

    def process_tag
      unless @@ps_tag
        @@ps_tag = Digest::MD5.hexdigest(Rails.root.to_s)[0..8]
      end
      @@ps_tag
    end
  end
end
