Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 24.hours

# Delayed::Worker.max_run_time = 5.minutes
# Delayed::Worker.read_ahead = 5
Delayed::Worker.delay_jobs = !(Rails.env.test? || Rails.env.cucumber?)

if Rails.env.development?
  # use a scaler that dynamically starts the worker process so
  # devs don't need to remember to start it.
  # 2021-06-14 NP:  We could set `delay_jobs` to false like we did for tests above
  # see: https://github.com/collectiveidea/delayed_job#gory-details
  Delayed::Backend::ActiveRecord::Job.send(:include, Delayed::Worker::Scaler)
end

Delayed::Worker.logger = Logger.new(
    File.join(Rails.root, 'log', 'delayed_job.log') )

