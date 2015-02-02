#############################################################
#  Application
#############################################################

set :deploy_to, "/web/portal"
set :branch, "master"

#############################################################
#  Servers
#############################################################

set :domain, "has.production.concord.org"
server domain, :app, :web
role :db, domain, :primary => true

# this currently isn't used, instead the files are proxied back to seymour
namespace :deploy do
  desc "link in the has resources folder"
  task :has_resource_symlink do
    run "ln -nfs #{shared_path}/public/resources #{release_path}/public/resources"
  end
end

after 'deploy:update_code', 'deploy:has_resource_symlink'

after "deploy:restart", "autoscaling:update"

## Autoscale EC2 / AMI / ELB Config:
# use `export AWS_ACCESS_KEY_ID='xxxxx'` in your shell?
# use `export AWS_SECRET_ACCESS_KEY='yyyy'` in your shell?
# set(:autoscaling_access_key_id, "PUTYOURAWSACCESSKEYIDHERE")
# set(:autoscaling_secret_access_key, "PUTYOURAWSSECRETACCESSKEYHERE")

set :autoscaling_region, "us-east-1e"
set :autoscaling_create_image, true
set :autoscaling_create_group, true
set :autoscaling_create_policy, true
set :autoscaling_create_launch_configuration, true

set(:autoscaling_instance_type, "c3.large")
# us-east-1d doesn't support the SSD volume time that we need so the regions are set explicitly here
set(:autoscaling_availability_zones, ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1e"])
set(:autoscaling_security_groups, %w(has))
set(:autoscaling_min_size, 1)
set(:autoscaling_max_size, 5)
set(:autoscaling_application, 'HasProdLB')
set(:autoscaling_require_keys, true)
set(:autoscaling_image_master_name, 'has-production') # will use 'stage' otherwise