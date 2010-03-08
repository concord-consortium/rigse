#############################################################
#  Application
#############################################################

set :deploy_to, "/web/production/geniverse"
set :branch, "geniverse-portal"

#############################################################
#  Servers
#############################################################

set :domain, "geniverse-portal.concord.org"
server domain, :app, :web
role :db, domain, :primary => true

after 'deploy:symlink', 'copy_index'

task :copy_index, :roles => :web do
  run "cp #{deploy_to}/shared/index.html #{current_path}/public/"
  sudo "chown root.root #{current_path}/public/index.html"
  sudo "chmod 444 #{current_path}/public/index.html"
end

# DISABLE SOME OF THE DESTRUCTIVE DB TASKS
namespace :db do
#  desc 'Loads the production database in db/production_data.sql on the remote server'
#  task :remote_db_load, :roles => :db, :only => { :primary => true } do
#    puts "This task is disabled for the production environment"
#  end
  
#  desc 'Uploads db/production_data.sql to the remote production environment from your local machine'
#  task :remote_db_upload, :roles => :db, :only => { :primary => true } do  
#    puts "This task is disabled for the production environment"
#  end

#  desc 'Uploads, inserts, and then cleans up the production data dump'
#  task :push_remote_db do
#    puts "This task is disabled for the production environment"
#  end
end