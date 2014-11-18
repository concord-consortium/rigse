#############################################################
#  Application
#############################################################

set :deploy_to, "/web/portal"
set :branch, "master"

#############################################################
#  Servers
#############################################################

set :domain, "has.staging.concord.org"
server domain, :app, :web
role :db, domain, :primary => true

namespace :deploy do
  desc "link in the has resources folder"
  task :has_resource_symlink do
    run "ln -nfs #{shared_path}/public/resources #{release_path}/public/resources"
  end
end

after 'deploy:update_code', 'deploy:has_resource_symlink'

## Autoscale EC2 / AMI / ELB Config:
# use `export AWS_ACCESS_KEY_ID='xxxxx'` in your shell?
# use `export AWS_SECRET_ACCESS_KEY='yyyy'` in your shell?
# set(:autoscaling_access_key_id, "PUTYOURAWSACCESSKEYIDHERE")
# set(:autoscaling_secret_access_key, "PUTYOURAWSSECRETACCESSKEYHERE")