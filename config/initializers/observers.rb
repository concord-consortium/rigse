# Don't startup observers if we are building the app for the first time because the
# tables haven't been created yet. The classes being observed will throw 
# errors accessing the models when running db:migrate from scratch
#
# This is one way to test to see if we got here running rake db:migrate:
#
#   unless ( File.basename($0) == "rake" && ARGV.include?("db:migrate") ) 
# 
# but it won't help when running a task like this the first time:
#
#   rake rigse:setup:new_rites_app
#
# So I'm using this method to find out if the standard "ActiveRecord::Base" 
# connection in the connection_pool is working:
#
#   ActiveRecord::Base.connection_handler.connection_pools["ActiveRecord::Base"].connected?
#  
# Nov 10 NP: This technique wasn't working, so, I figued we would just surround w/ begin / rescue
# if ActiveRecord::Base.connection_handler.connection_pools["ActiveRecord::Base"].connected?
begin
  ActiveRecord::Base.observers = :user_observer, :investigation_observer
  ActiveRecord::Base.instantiate_observers
  puts "Started observers"
rescue
  # intersetingly Rails::logger doesn't seem to be working here, so I am using ugly puts for now:
  puts "Couldn't start observers #{$!}"
  puts "This might be because you have not setup the appropriate database tables yet... "
  puts "see config/initializers/observers.rb for more information."
end
