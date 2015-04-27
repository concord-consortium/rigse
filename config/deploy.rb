require "bundler/capistrano"
require 'capistrano/ext/multistage'
require 'capistrano/cowboy'

# experimental: create autoscaling instances from EC2 instance
require "capistrano-autoscaling"




require 'haml'
require File.expand_path('../../lib/yaml_editor', __FILE__)

set :stages, %w(
  rites-staging rites-production rites-ri-production
  itsisu-dev itsisu-staging itsisu-production
  smartgraphs-staging smartgraphs-production smartgraphs-aws1
  has-dev has-staging has-production has-aws1
  geniverse-dev geniverse-production
  geniverse-aws-testing geniverse-aws-production
  genigames-baseline-production genigames-ungamed-production
  genigames-dev genigames-staging genigames-production
  interactions-staging interactions-production
  genomedynamics-dev genomedynamics-staging
  sparks-dev sparks-staging sparks-production sparks-aws1
  learn-staging learn-production
  ngss-assessment-staging ngss-assessment-production
  codap-production
  xproject-dev
  inquiryspace-production inquiryspace-staging)

set :default_stage, "development"

set :rake,           "bundle exec rake"

def render(file,opts={})
  template = File.read(file)
  haml_engine = Haml::Engine.new(template)
  output = haml_engine.render(nil,opts)
  output
end

def run_remote_rake(taskname, ignore_fail=false)
    run "cd #{deploy_to}/#{current_dir} && " +
    "bundle exec rake RAILS_ENV=#{rails_env} #{taskname} --trace" +
    (ignore_fail ? "; true" : "")
end

#############################################################
#  Maintenance mode
#############################################################
task :disable_web, :roles => :web do
  on_rollback { delete "#{shared_path}/system/maintenance.html"    }

  site_name = ask("site name? ") { |q| q.default = "RITES"         }
  back_up   = ask("back up?   ") { |q| q.default = "in 12 minutes" }
  message   = ask("message?   ") { |q| q.default = ""              }

  maintenance = render("./app/views/layouts/maintenance.haml",
                       {
                         :back_up   => back_up,
                         :message   => message,
                         :site_name => site_name
                       })

  # File.open(File.expand_path("~/Desktop/index.html"),"w") do |f|
  #   f.write(maintenance)
  # end
  run "mkdir -p #{shared_path}/system/"
  put maintenance, "#{shared_path}/system/maintenance.html",
                   :mode => 0644
end
task :enable_web, :roles => :web do
  run "rm #{shared_path}/system/maintenance.html"
end

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
ssh_options[:compression] = false
set :use_sudo, true
set :scm_verbose, true
set :rails_env, "production"

set :user, "deploy"

#############################################################
#  Git
#############################################################

set :scm, :git
set :branch, "production"
set :git_enable_submodules, 1
# wondering if we can do something special for this? create
# a special deploy user on github?
set(:scm_user) do
  Capistrano::CLI.ui.ask "Enter your git username: "
end
set(:scm_passphrase) do
  Capistrano::CLI.password_prompt( "Enter your git password: ")
end
set :repository, "git://github.com/concord-consortium/rigse.git"
set :deploy_via, :remote_cache

#############################################################
#  DB
#############################################################

namespace :db do
  desc 'Dumps the production database to db/production_data.sql on the remote server'
  task :remote_db_dump, :roles => :db, :only => { :primary => true } do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} db:dump --trace"
  end

  desc 'Loads the production database in db/production_data.sql on the remote server'
  task :remote_db_load, :roles => :db, :only => { :primary => true } do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} db:load --trace"
  end

  desc '[NOTE: use "fetch_remote_db" instead!] Downloads db/production_data.sql from the remote production environment to your local machine'
  task :remote_db_download, :roles => :db, :only => { :primary => true } do
    remote_db_compress
    ssh_compression = ssh_options[:compression]
    ssh_options[:compression] = true
    download("#{deploy_to}/#{current_dir}/db/production_data.sql.gz", "db/production_data.sql.gz", :via => :scp)
    ssh_options[:compression] = ssh_compression
  end

  desc '[NOTE: use "push_remote_db" instead!] Uploads db/production_data.sql to the remote production environment from your local machine'
  task :remote_db_upload, :roles => :db, :only => { :primary => true } do
    ssh_compression = ssh_options[:compression]
    ssh_options[:compression] = true
    `gzip -f db/production_data.sql` unless File.exists?("db/production_data.sql.gz")
    upload("db/production_data.sql.gz", "#{deploy_to}/#{current_dir}/db/production_data.sql.gz", :via => :scp)
    ssh_options[:compression] = ssh_compression
    remote_db_uncompress
  end

  task :remote_db_compress, :roles => :db, :only => { :primary => true } do
    run "gzip -f #{deploy_to}/#{current_dir}/db/production_data.sql"
  end

  task :remote_db_uncompress, :roles => :db, :only => { :primary => true } do
    run "gunzip -f #{deploy_to}/#{current_dir}/db/production_data.sql.gz"
  end

  desc 'Cleans up data dump file'
  task :remote_db_cleanup, :roles => :db, :only => { :primary => true } do
    execute_on_servers(options) do |servers|
      self.sessions[servers.first].sftp.connect do |tsftp|
        tsftp.remove "#{deploy_to}/#{current_dir}/db/production_data.sql"
        tsftp.remove "#{deploy_to}/#{current_dir}/db/production_data.sql.gz"
      end
    end
  end

  desc 'Dumps, downloads and then cleans up the production data dump'
  task :fetch_remote_db do
    remote_db_dump
    remote_db_download
    remote_db_cleanup
  end

  desc 'Uploads, inserts, and then cleans up the production data dump'
  task :push_remote_db do
    remote_db_upload
    remote_db_load
    remote_db_cleanup
  end

  desc "Pulls uploaded attachments from the remote server"
  task :fetch_remote_attachments, :roles => :web do
    remote_dir  = "#{shared_path}/system/attachments/"
    local_dir   = "public/system/attachments/"
    run_locally "rsync -avx --delete #{fetch(:user)}@#{domain}:#{remote_dir} #{local_dir}"
  end

  desc "Pushes uploaded attachments to the remote server"
  task :push_local_attachments, :roles => :web do
    remote_dir  = "#{shared_path}/system/attachments/"
    local_dir   = "public/system/attachments/"
    run_locally "rsync -avx --delete #{local_dir} #{fetch(:user)}@#{domain}:#{remote_dir}"
  end

end

namespace :deploy do
  # By default deploy:cleanup uses sudo(!)
  # We don't want this when using a deploy user
  set :use_sudo, false

  #############################################################
  #  Passenger
  #############################################################

  # Restart passenger on deploy
  desc "Restarting passenger with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with passenger"
    task t, :roles => :app do ; end
  end

  desc "setup a new version of rigse from-scratch using bundle exec rake task of similar name"
  task :setup_new_app do
    run "cd #{deploy_to}/current; RAILS_ENV=production bundle exec rake app:setup:new_rites_app --trace"
  end

  desc "setup directory remote directory structure"
  task :make_directory_structure do
    run <<-CMD
      mkdir -p #{deploy_to}/releases &&
      mkdir -p #{shared_path} &&
      mkdir -p #{shared_path}/config &&
      mkdir -p #{shared_path}/log &&
      mkdir -p #{shared_path}/pids &&
      mkdir -p #{shared_path}/sis_import_data &&
      mkdir -p #{shared_path}/config/nces_data &&
      mkdir -p #{shared_path}/public/otrunk-examples &&
      mkdir -p #{shared_path}/public/installers &&
      mkdir -p #{shared_path}/config/initializers &&
      mkdir -p #{shared_path}/system/attachments &&
      mkdir -p #{shared_path}/solr/data &&
      mkdir -p #{shared_path}/solr/pids &&
      touch #{shared_path}/config/database.yml &&
      touch #{shared_path}/config/settings.yml &&
      touch #{shared_path}/config/installer.yml &&
      touch #{shared_path}/config/sis_import_data.yml &&
      touch #{shared_path}/config/mailer.yml &&
      touch #{shared_path}/config/initializers/site_keys.rb &&
      touch #{shared_path}/config/initializers/subdirectory.rb &&
      touch #{shared_path}/config/database.yml &&
      touch #{shared_path}/config/google_analytics.yml
      touch #{shared_path}/config/padlet.yml
    CMD

    # support for running a SproutCore app from within the public directory
    run "mkdir -p #{shared_path}/public/static"
    run "mkdir -p #{shared_path}/public/labels"
  end

  desc "link in some shared resources, such as database.yml"
  task :shared_symlinks do
    run <<-CMD
      ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
      ln -nfs #{shared_path}/config/settings.yml #{release_path}/config/settings.yml &&
      ln -nfs #{shared_path}/config/installer.yml #{release_path}/config/installer.yml &&
      ln -nfs #{shared_path}/config/paperclip.yml #{release_path}/config/paperclip.yml &&
      ln -nfs #{shared_path}/config/aws_s3.yml #{release_path}/config/aws_s3.yml &&
      ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml &&
      ln -nfs #{shared_path}/config/padlet.yml #{release_path}/config/padlet.yml &&
      ln -nfs #{shared_path}/config/sis_import_data.yml #{release_path}/config/sis_import_data.yml &&
      ln -nfs #{shared_path}/config/mailer.yml #{release_path}/config/mailer.yml &&
      ln -nfs #{shared_path}/config/initializers/site_keys.rb #{release_path}/config/initializers/site_keys.rb &&
      ln -nfs #{shared_path}/config/initializers/subdirectory.rb #{release_path}/config/initializers/subdirectory.rb &&
      ln -nfs #{shared_path}/public/otrunk-examples #{release_path}/public/otrunk-examples &&
      ln -nfs #{shared_path}/public/installers #{release_path}/public/installers &&
      ln -nfs #{shared_path}/config/nces_data #{release_path}/config/nces_data &&
      ln -nfs #{shared_path}/sis_import_data #{release_path}/sis_import_data &&
      ln -nfs #{shared_path}/system #{release_path}/public/system &&
      ln -nfs #{shared_path}/solr/data #{release_path}/solr/data &&
      ln -nfs #{shared_path}/solr/pids #{release_path}/solr/pids &&
      ln -nfs #{shared_path}/config/app_environment_variables.rb #{release_path}/config/app_environment_variables.rb
    CMD
    # This is part of the setup necessary for using newrelics reporting gem
    # run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
    run "ln -nfs #{shared_path}/config/google_analytics.yml #{release_path}/config/google_analytics.yml"

    # support for running SproutCore app from the public directory
    run "ln -nfs #{shared_path}/public/static #{release_path}/public/static"
    run "cd #{release_path}/public; for i in `ls #{shared_path}/public/labels`; do rm $i; ln -s #{shared_path}/public/labels/$i $i; done"

    # by default capistrano creates symlinks for tmp/pids->pids, public/system->system, and log->log
  end

  desc "install required gems for application"
  task :install_gems do
    sudo "sh -c 'cd #{deploy_to}/current; bundle exec rake gems:install'"
  end

  desc "set correct file permissions of the deployed files"
  task :set_permissions, :roles => :app do
    # sudo "chown -R apache.users #{deploy_to}"
    # sudo "chmod -R g+rw #{deploy_to}"

    # Grant write access to the paperclip attachments folder
    # sudo "chown -R apache.users #{shared_path}/system/attachments"
    # sudo "chmod -R g+rw #{shared_path}/system/attachments"
  end

  # asset compilation included in Capfile load 'deploy/assets'
  # desc "Create asset packages for production"
  # task :create_asset_packages, :roles => :app do
  #   # run "cd #{deploy_to}/current && bundle exec compass compile --sass-dir public/stylesheets/scss/ --css-dir public/stylesheets/ -s compact --force"
  #   run "cd #{deploy_to}/current && bundle exec rake assets:precompile --trace"
  # end
end

namespace :setup do
  desc "ensure that the database exists, is migrated and has default users, roles, projects, etc"
  task :init_database, :roles => :app do
    run_remote_rake "db:create"
    run_remote_rake "db:migrate"
    run_remote_rake "app:setup:default_users_roles"
    run_remote_rake "app:setup:default_settings"
    run_remote_rake "sunspot:solr:start", true
    run_remote_rake "app:setup:default_portal_resources"
  end

   # 2013_04_01 NP:
  desc "ensure that one default project exists"
  task :create_default_settings, :roles => :app do
    run_remote_rake "app:setup:default_settings"
  end

  desc "setup the NCES districts: download and configure NCES districts"
  task :districts, :roles => :app do
    run_remote_rake "portal:setup:download_nces_data --trace"  
    run_remote_rake "portal:setup:import_nces_from_files --trace"
    run_remote_rake "portal:setup:create_districts_and_schools_from_nces_data --trace"
  end 
end

#############################################################
#  IMPORT
#############################################################

namespace :import do

  desc 'import grade span expectations from files in config/rigse_data/'
  task :import_gses_from_file, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:setup:import_gses_from_file --trace"
  end

  desc"Generate OtrunkExamples:: Rails models from the content in the otrunk-examples dir."
  task :generate_otrunk_examples_rails_models, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:import:generate_otrunk_examples_rails_models --trace"
  end

  desc"Create git clone of otrunk-examples in <shared_path>/public/otrunk-examples"
  task :create_git_clone_of_otrunk_examples, :roles => :app do
    run "cd #{shared_path} && " +
      "mkdir -p public && " +
      "cd public && " +
      "git clone git://github.com/concord-consortium/otrunk-examples.git"
  end

  desc"Download nces data files from NCES websites"
  task :download_nces_data, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} portal:setup:download_nces_data --trace"
  end

  desc "Import nces data from files: config/nces_data/* -- uses APP_CONFIG[:states_and_provinces] if defined to filter on states"
  task :nces_data_from_files, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} portal:setup:import_nces_from_files --trace"
  end

  desc"reload the default probe and vendor_interface configurations."
  task :reload_probe_configurations, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} db:backup:load_probe_configurations --trace"
  end

  desc "Import RINET data"
  task :import_sis_import_data, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
    "bundle exec rake RAILS_ENV=#{rails_env} app:import:rinet --trace"
  end

  desc "Restore couchdb from S3"
  task :restore_couchdb_from_backup, :roles => :app do
    sudo "/usr/bin/restore_couchdb.sh"
  end
end

#############################################################
#  DELETE
#############################################################

namespace :delete do

  desc"Delete the otrunk-example models (Rails models)."
  task :otrunk_example_models, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:import:delete_otrunk_example_models --trace"
  end

end

#############################################################
#  Convert
#############################################################

namespace :convert do
  desc 'wrap orphaned activities in a parent investigation'
  task :wrap_orphaned_activities_in_investigations, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:make:investigations --trace"
  end

  desc 'set new grade_span_expectation attribute: gse_key'
  task :set_gse_keys, :roles => :db, :only => { :primary => true } do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:set_gse_keys --trace"
  end

  desc 'find page_elements whithout owners and reclaim them'
  task :reclaim_page_elements, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:reclaim_elements --trace"
  end

  desc 'transfer any Investigations owned by the anonymous user to the site admin user'
  task :transfer_investigations_owned_by_anonymous, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:transfer_investigations_owned_by_anonymous --trace"
  end

  desc 'deep set user ownership on all investigations'
  task :deep_set_user_on_all_investigations, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:run_deep_set_user_on_all_investigations --trace"
  end

  desc 'clean up teacher notes owned by the wrong user'
  task :clean_teacher_notes, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:clean_teacher_notes --trace"
  end

  desc 'add the author role to all users who have authored an Investigation'
  task :add_author_role_to_authors, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:add_author_role_to_authors --trace"
  end

  desc "set publication_status to 'draft' for all Investigations without publication_status"
  task :set_publication_status_to_draft, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:pub_status --trace"
  end

  desc "Data Collectors with a static graph_type to a static attribute; Embeddable::DataCollectors with a graph_type_id of nil to Sensor"
  task :data_collectors_with_invalid_graph_types, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:data_collectors_with_invalid_graph_types --trace"
  end

  desc "copy truncated Embeddable::Xhtml from Embeddable::Xhtml#content, Embeddable::OpenResponse and Embeddable::MultipleChoice#prompt into name"
  task :copy_truncated_xhtml_into_name, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:copy_truncated_xhtml_into_name --trace"
  end

  desc "Create bundle and console loggers for learners"
  task :create_bundle_and_console_loggers_for_learners, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:create_bundle_and_console_loggers_for_learners --trace"
  end

  # Tuesday, August 11, 2009

  desc "Find and report on invalid Dataservice::BundleContent objects"
  task :find_and_report_on_invalid_dataservice_bundle_content_objects, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:find_and_report_on_invalid_dataservice_bundle_content_objects --trace"
  end

  desc "Find and delete invalid Dataservice::BundleContent objects"
  task :find_and_delete_invalid_dataservice_bundle_content_objects, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:find_and_delete_invalid_dataservice_bundle_content_objects --trace"
  end

  desc "generate otml, valid_xml, and empty attributes for BundleContent objects"
  task :generate_otml_valid_xml_and_empty_attributes_for_bundle_content_objects, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:generate_otml_valid_xml_and_empty_attributes_for_bundle_content_objects --trace"
  end

  # Thursday October 8, 2009

  desc "Create default users, roles, district, school, course, and class, and greade_levels"
  task :default_users_roles, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:setup:default_users_roles --trace"
  end

  desc "Create default portal resources: district, school, course, and class, investigation and grades"
  task :default_portal_resources, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:setup:default_portal_resources --trace"
  end

  desc "Create districts and schools from NCES records for States listed in settings.yml"
  task :create_districts_and_schools_from_nces_data, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} portal:setup:create_districts_and_schools_from_nces_data --trace"
  end

  # Wed Dec 2nd
  desc "Convert Existing Clazzes so that multiple Teachers can own a clazz. (many to many change)"
  task :convert_clazzes_to_multi_teacher, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:convert_clazzes_to_multi_teacher --trace"
  end

  # Wed Jan 6 2010
  desc "Fixup inner pages: add static_page associations (run deploy:migrate first!)"
  task :add_static_pages_to_inner_pages, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:add_static_page_to_inner_pages --trace"
  end

  # Feb 3, 2010
  desc "Extract and process learner responses from existing OTrunk bundles"
  task :extract_learner_responses_from_existing_bundles, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:extract_learner_responses_from_existing_bundles --trace"
  end

  desc "Erase all learner responses and reset the tables"
  task :erase_all_learner_responses_and_reset_the_tables, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:erase_all_learner_responses_and_reset_the_tables --trace"
  end

  #Feb 4, 2010
  desc "Convert all index-based MultipleChoice references in existing OTrunk bundles to local_id-based references."
  task :convert_choice_answers_to_local_ids, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:convert_choice_answers_to_local_ids --trace"
  end

  # seb: 20100513
  desc "Populate the new leaid, state, and zipcode portal district and school attributes with data from the NCES tables"
  task :populate_new_district_and_school_attributes_with_data_from_nces_tables, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:convert:populate_new_district_and_school_attributes_with_data_from_nces_tables --trace"
  end

  # seb: 20101019
  desc "Reset all activity position information"
  task :reset_activity_positions, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "bundle exec rake RAILS_ENV=#{rails_env} app:fixup:reset_activity_positions --trace"
  end

  # seb: 20110126
  # See commit: Add "offerings_count" cache counter to runnables
  # https://github.com/concord-consortium/rigse/commit/dadea520e3cda26a721e01428527a86222143c68
  desc "Recalculate the 'offerings_count' field for runnable objects"
  task :reset_offering_counts, :roles => :app do
    # remove investigation cache files
    run "rm -rf #{deploy_to}/#{current_dir}/public/investigations/*"
    run "cd #{deploy_to}/#{current_dir} && bundle exec rake RAILS_ENV=#{rails_env} offerings:set_counts --trace"
  end

  # NP 20110512
  desc "create an investigation to test all know probe_type / calibration combinations"
  task :create_probe_testing_investigation, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
        "bundle exec rake RAILS_ENV=#{rails_env} app:setup:create_probe_testing_investigation --trace"
  end
  # seb: 20110516
  # See commit: District#destroy cascades through dependents
  # https://github.com/concord-consortium/rigse/commit/1c9e26919decfe322e0bca412b4fa41928b7108a
  desc "*** WARNING *** Delete all real districts, schools, teachers, students, offerings, etc except for the virtual site district and school"
  task :delete_all_real_schools, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && bundle exec rake RAILS_ENV=#{rails_env} app:schools:delete_all_real_schools --trace"
  end

  # seb: 20110715
  # moved repo to https://github.com/concord-consortium/rigse
  desc "change git remote url for origin to git://github.com/concord-consortium/rigse.git"
  task :change_git_origin_url_to_concord_consortium, :roles => :app do
    run("cd #{shared_path}/cached-copy; git remote set-url origin git://github.com/concord-consortium/rigse.git")
  end

end

#
# generake (hehe) cap task to run rake tasks.
# found here: http://stackoverflow.com/questions/312214/how-do-i-run-a-rake-task-from-capistrano
namespace :rake_tasks do
  desc "Run a rake task: cap staging rake:invoke task=a_certain_task"
  # run like: cap staging rake:invoke task=a_certain_task
  task :invoke do
    run("cd #{deploy_to}/current; bundle exec rake #{ENV['task']} RAILS_ENV=#{rails_env}")
 rake #{ENV['task']} RAILS_ENV=#{rails_env}")
  end
end

#############################################################
#  INSTALLER:  Help to create installers on various hosts
#############################################################

namespace :installer do

  desc 'copy config -- copy the local installer.yml to the server. For bootstraping a fresh instance.'
  task :copy_config do
    upload("config/installer.yml", "#{deploy_to}/#{current_dir}/config/installer.yml", :via => :scp)
  end

  desc 'create: downloads remote config, caches remote jars, builds installer, uploads new config and installer images'
  task :create, :roles => :app do
    # download the current config file to local config
    %x[cp config/installer.yml config/installer.yml.mine]
    download("#{deploy_to}/#{current_dir}/config/installer.yml", "config/installer.yml", :via => :scp)
    # build the installers

    # the yaml editor is broken...
    # editor = YamlEditor.new('./config/installer.yml')
    # editor.edit
    # editor.write_file
    # so instead just give the user a chance to manual edit the installer.yml file
    Capistrano::CLI.ui.ask("You can now edit the config/installer.yml file, press enter when done.")

    %x[bundle exec rake build:installer:rebuild_all ]

    # post the config back up to remote server
    upload("config/installer.yml", "#{deploy_to}/#{current_dir}/config/installer.yml", :via => :scp)
    # copy the installers themselves up to the remote server
    Dir.glob("resources/bitrock_installer/installers/*") do |filename|
      basename = File.basename(filename)
      puts "copying #{filename}"
      upload(filename, "#{deploy_to}/#{current_dir}/public/installers/#{basename}", :via => :scp)
    end
    %x[cp config/installer.yml.mine config/installer.yml]
  end

end

namespace 'account_data' do
  desc 'upload_csv_for_district: copy the local csv import files to remote for district (set district=whatever)'
  task 'upload_csv_for_district' do
    district = ENV['district']
    if district
      domain = ENV['domain'] || 'rinet_sakai'
      district_root = File.join('sis_import_data','districts',domain, 'csv')
      from_dir = File.join('sis_import_data','districts',domain, 'csv',district)
      to_dir   = File.join(deploy_to,current_dir,'sis_import_data','districts',domain, 'csv')
      upload(from_dir, to_dir, :via => :scp, :recursive => true)
    end
  end
end

# Tasks to interact with Solr and SunSpot
namespace :solr do
  desc "start solr"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:start"
  end
  desc "stop solr"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:stop ;true"
  end

  desc "restart solr"
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end

  desc "stop solr, remove data, start solr, reindex all records"
  task :hard_reindex, :roles => :app do
    stop
    run "rm -rf #{shared_path}/solr/data/*"
    start
    reindex
  end

  desc "simple reindex" #note the yes | reindex to avoid the nil.chomp error
  task :reindex, roles: :app do
    run "cd #{current_path} && yes | RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:reindex"
  end
end

before 'deploy:restart', 'deploy:set_permissions'
before 'deploy:update_code', 'deploy:make_directory_structure'
after 'deploy:update_code', 'deploy:shared_symlinks'
# see load 'deploy/assets' in Capfile
# after 'deploy:create_symlink', 'deploy:create_asset_packages'
after 'deploy:shared_symlinks', 'deploy:cleanup'
after 'installer:create', 'deploy:restart'

# start the delayed_job worker
# use a prefix incase multiple apps are deployed to the same server
require "delayed/recipes"

# need to use the &block syntax so that deploy_to is correctly setup
set(:delayed_job_args) { "--prefix '#{deploy_to}'" }
after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"
after "deploy:restart", "solr:restart"

# Make the default behavior be to NOT autoscale
set(:autoscaling_instance_type, "c3.large")
set :autoscaling_create_image, false
set :autoscaling_create_group, false
set :autoscaling_create_policy, false
set :autoscaling_create_launch_configuration, false
set(:autoscaling_require_keys, false)
