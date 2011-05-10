#############################################################
#  Application
#############################################################

# TODO: keep the units server alive and happy.
# dont deploy itsisu-production to it.
# set :deploy_to, "/web/production/itsisu_units"
# set :branch, "itsisu-units"

set :deploy_to, "/web/portal"
set :branch, "itsisu-production"


#############################################################
#  Servers
#############################################################

#set :domain, "itsisu.units.concord.org"
set :domain, "ruby-vm5.concord.org"

server domain, :app, :web
role :db, domain, :primary => true
# DISABLE SOME OF THE DESTRUCTIVE DB TASKS
namespace :db do
 desc 'Loads the production database in db/production_data.sql on the remote server'
 task :remote_db_load, :roles => :db, :only => { :primary => true } do
   puts "This task is disabled for the production environment"
 end
  
 desc 'Uploads db/production_data.sql to the remote production environment from your local machine'
 task :remote_db_upload, :roles => :db, :only => { :primary => true } do  
   puts "This task is disabled for the production environment"
 end

 desc 'Uploads, inserts, and then cleans up the production data dump'
 task :push_remote_db do
   puts "This task is disabled for the production environment"
 end
end
