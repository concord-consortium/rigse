# Controls for spawning a background processor if one doesn't already exist
# whenever delayed jobs are created.
# 2021-06-14 NP: This worker will continue running. When we switch to
# ActiveJob, we can use the built-in in-memory job queuing implementation
require_relative "job_manager"

module Delayed
  class Worker
    module Scaler
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          after_commit(on: :create) do
            self.class.up
          end
        end
      end

      module ClassMethods
        @@job_manager = Delayed::Worker::JobManager.new
        @@last_start = 1.day.ago

        def up
          if workers.zero? && ((Time.now - @@last_start) > 30)
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
  end
end
