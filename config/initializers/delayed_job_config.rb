# Delayed::Worker.destroy_failed_jobs = false
# Delayed::Worker.sleep_delay = 60
# Delayed::Worker.max_attempts = 3
# Delayed::Worker.max_run_time = 5.minutes

# this was being set to false even in the dev environment, force it true for 
# testing locally
Delayed::Worker.delay_jobs = !Rails.env.test? && !defined?(JRUBY)

# use the the workless gem to automatically fireup a delayed job worker process
Delayed::Job.scaler = :local
