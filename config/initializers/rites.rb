# Don't create initial settings if we are building the app for the first time because the
# tables haven't been created yet. 
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
if ActiveRecord::Base.connection_handler.connection_pools["ActiveRecord::Base"].connected?
  Admin::Project.create_or_update__default_project_from_settings_yml
end