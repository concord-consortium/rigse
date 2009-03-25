#############################################################
#  Application
#############################################################

set :application, "rites"
set :deploy_to, "/web/rites.concord.org"

#############################################################
#  Settings
#############################################################

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, true
set :scm_verbose, true
set :rails_env, "production" 

#############################################################
#  Servers
#############################################################

# set :user, "npaessel"
set :domain, "rites.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true

#############################################################
#  Git
#############################################################

set :scm, :git
set :branch, "master"
# wondering if we can do something special for this? create
# a special deploy user on github?
set :scm_user, 'knowuh'
set :scm_passphrase, "PASSWORD"
set :repository, "git://github.com/stepheneb/rigse.git"
set :deploy_via, :remote_cache

#############################################################
#  Passenger
#############################################################

namespace :deploy do
    
  # Restart passenger on deploy
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
end
