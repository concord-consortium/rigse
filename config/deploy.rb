set :stages, %w(
  rites-dev rites-staging rites-production
  itsisu-dev itsisu-staging itsisu-production 
  smartgraphs-dev smartgraphs-staging smartgraphs-production
  has-dev has-staging has-production
  geniverse-dev geniverse-production
  xproject-dev
  genomedynamics-dev genomedynamics-staging genomedynamics-production
  fall2009 jnlp-staging seymour
  sparks-dev)
set :default_stage, "development"
# require File.expand_path("#{File.dirname(__FILE__)}/../vendor/gems/capistrano-ext-1.2.1/lib/capistrano/ext/multistage")
require 'capistrano/ext/multistage'
require 'haml'

require 'lib/yaml_editor'
require "bundler/capistrano"
def render(file,opts={})
  template = File.read(file)
  haml_engine = Haml::Engine.new(template)
  output = haml_engine.render(nil,opts)
  output
end

#############################################################
#  Maintenance mode
#############################################################
task :disable_web, :roles => :web do
  on_rollback { delete "#{shared_path}/system/maintenance.html" }

  maintenance = render("./app/views/layouts/maintenance.haml", 
                       {
                         :back_up => ENV['BACKUP'],
                         :reason => ENV['REASON'],
                         :message => ENV['MESSAGE']
                       })

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
set :repository, "git://github.com/stepheneb/rigse.git"
set :deploy_via, :remote_cache

#############################################################
#  DB
#############################################################

namespace :db do
  desc 'Dumps the production database to db/production_data.sql on the remote server'
  task :remote_db_dump, :roles => :db, :only => { :primary => true } do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} db:dump --trace" 
  end
  
  desc 'Loads the production database in db/production_data.sql on the remote server'
  task :remote_db_load, :roles => :db, :only => { :primary => true } do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} db:load --trace" 
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

  desc 'Copies config/initializers/site_keys.rb from the remote environment to your local machine'
  task :fetch_remote_site_keys, :roles => :app do
    download("#{deploy_to}/shared/config/initializers/site_keys.rb", "config/initializers/site_keys.rb", :via => :sftp)
  end
  
  desc 'Copies config/initializers/site_keys.rb from the remote environment to your local machine'
  task :push_local_site_keys, :roles => :app do
    upload("config/initializers/site_keys.rb", "#{deploy_to}/shared/config/initializers/site_keys.rb", :via => :sftp)
  end

  desc "Pulls uploaded attachments from the remote server"
  task :fetch_remote_attachments, :roles => :web do 
    remote_dir  = "#{shared_path}/system/attachments/"
    local_dir   = "public/system/attachments/"
    run_locally "rsync -avx --delete #{domain}:#{remote_dir} #{local_dir}"
  end
  
  desc "Pushes uploaded attachments to the remote server"
  task :push_local_attachments, :roles => :web do 
    remote_dir  = "#{shared_path}/system/attachments/"
    local_dir   = "public/system/attachments/"
    run_locally "rsync -avx --delete #{local_dir} #{domain}:#{remote_dir}"
  end

end

namespace :deploy do
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

  desc "setup a new version of rigse from-scratch using rake task of similar name"
  task :setup_new_app do
    run "cd #{deploy_to}/current; RAILS_ENV=production rake rigse:setup:new_rites_app --trace"
  end
  
  desc "setup directory remote directory structure"
  task :make_directory_structure do
    run "mkdir -p #{deploy_to}/releases"
    run "mkdir -p #{shared_path}"
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/log"
    run "mkdir -p #{shared_path}/rinet_data"
    run "mkdir -p #{shared_path}/config/nces_data"
    run "mkdir -p #{shared_path}/public/otrunk-examples"
    run "mkdir -p #{shared_path}/public/sparks-content"
    run "mkdir -p #{shared_path}/public/installers"  
    run "mkdir -p #{shared_path}/config/initializers"
    run "mkdir -p #{shared_path}/system/attachments" # paperclip file attachment location
    run "touch #{shared_path}/config/database.yml"
    run "touch #{shared_path}/config/settings.yml"
    run "touch #{shared_path}/config/installer.yml"
    run "touch #{shared_path}/config/rinet_data.yml"
    run "touch #{shared_path}/config/mailer.yml"
    run "touch #{shared_path}/config/initializers/site_keys.rb"
    run "touch #{shared_path}/config/initializers/subdirectory.rb"
    run "touch #{shared_path}/config/database.yml"
  end

  desc "link in some shared resources, such as database.yml"
  task :shared_symlinks do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/settings.yml #{release_path}/config/settings.yml"
    run "ln -nfs #{shared_path}/config/installer.yml #{release_path}/config/installer.yml"    
    run "ln -nfs #{shared_path}/config/rinet_data.yml #{release_path}/config/rinet_data.yml"
    run "ln -nfs #{shared_path}/config/mailer.yml #{release_path}/config/mailer.yml"
    run "ln -nfs #{shared_path}/config/initializers/site_keys.rb #{release_path}/config/initializers/site_keys.rb"
    run "ln -nfs #{shared_path}/config/initializers/subdirectory.rb #{release_path}/config/initializers/subdirectory.rb"
    run "ln -nfs #{shared_path}/public/otrunk-examples #{release_path}/public/otrunk-examples"
    run "ln -nfs #{shared_path}/public/sparks-content #{release_path}/public/sparks-content"
    run "ln -nfs #{shared_path}/public/installers #{release_path}/public/installers"
    run "ln -nfs #{shared_path}/config/nces_data #{release_path}/config/nces_data"
    run "ln -nfs #{shared_path}/rinet_data #{release_path}/rinet_data"
    run "ln -nfs #{shared_path}/system #{release_path}/public/system" # paperclip file attachment location
    # This is part of the setup necessary for using newrelics reporting gem 
    # run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
    run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
  end
    
  desc "install required gems for application"
  task :install_gems do
    sudo "sh -c 'cd #{deploy_to}/current; rake gems:install'"
  end
  
  desc "set correct file permissions of the deployed files"
  task :set_permissions, :roles => :app do
    # sudo "chown -R apache.users #{deploy_to}"
    # sudo "chmod -R g+rw #{deploy_to}"
    
    # Grant write access to the paperclip attachments folder
    # sudo "chown -R apache.users #{shared_path}/system/attachments"
    # sudo "chmod -R g+rw #{shared_path}/system/attachments"
  end
  
  desc "Create asset packages for production" 
  task :create_asset_packages, :roles => :app do
    run "cd #{deploy_to}/current && bundle exec compass --sass-dir public/stylesheets/sass/ --css-dir public/stylesheets/ -s compressed --force"
    run "cd #{deploy_to}/current && rake asset:packager:build_all --trace"
  end
  
end

#############################################################
#  IMPORT
#############################################################

namespace :import do
  
  desc 'import grade span expectations from files in config/rigse_data/'
  task :import_gses_from_file, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:setup:import_gses_from_file --trace" 
  end
  
  desc 'erase and import ITSI activities from the ITSI DIY'
  task :erase_and_import_itsi_activities, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:import:erase_and_import_itsi_activities --trace" 
  end

  desc 'erase and import ITSI Activities from the ITSI DIY collected as Units from the CCPortal'
  task :erase_and_import_ccp_itsi_units, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:import:erase_and_import_ccp_itsi_units --trace" 
  end

  desc "generate names for existing MavenJnlpServers that don't have them"
  task :generate_names_for_maven_jnlp_servers, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:jnlp:generate_names_for_maven_jnlp_servers --trace" 
  end

  desc "generate MavenJnlp resources from jnlp servers in settings.yml"
  task :generate_maven_jnlp_resources, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:jnlp:generate_maven_jnlp_resources --trace" 
  end

  desc"Generate OtrunkExamples:: Rails models from the content in the otrunk-examples dir."
  task :generate_otrunk_examples_rails_models, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:import:generate_otrunk_examples_rails_models --trace" 
  end

  desc"Create git clone of otrunk-examples in <shared_path>/public/otrunk-examples"
  task :create_git_clone_of_otrunk_examples, :roles => :app do
    run "cd #{shared_path} && " +
      "mkdir -p public && " +
      "cd public && " +
      "git clone git://github.com/stepheneb/otrunk-examples.git"
  end

  desc"Download nces data files from NCES websites"
  task :download_nces_data, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} portal:setup:download_nces_data --trace" 
  end

  desc "Import nces data from files: config/nces_data/* -- uses APP_CONFIG[:states_and_provinces] if defined to filter on states"
  task :nces_data_from_files, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} portal:setup:import_nces_from_files --trace" 
  end

  desc"reload the default probe and vendor_interface configurations."
  task :reload_probe_configurations, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} db:backup:load_probe_configurations --trace" 
  end

  desc "Import RINET data"
  task :import_rinet_data, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
    "rake RAILS_ENV=#{rails_env} rigse:import:rinet --trace" 
  end
  
  # 01/27/2010
  desc "create or update a git svn clone of sparks-content"
  task :create_or_update_sparks_content, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
    "rake RAILS_ENV=#{rails_env} rigse:import:create_or_update_sparks_content --trace" 
  end
  
end

#############################################################
#  DELETE
#############################################################

namespace :delete do
  
  desc "delete all the MavenJnlp resources"
  task :maven_jnlp_resources, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:jnlp:delete_maven_jnlp_resources --trace" 
  end
  
  desc"Delete the otrunk-example models (Rails models)."
  task :otrunk_example_models, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:import:delete_otrunk_example_models --trace" 
  end

end

#############################################################
#  Convert
#############################################################

namespace :convert do
  desc 'wrap orphaned activities in a parent investigation'
  task :wrap_orphaned_activities_in_investigations, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:make:investigations --trace" 
  end

  desc 'set new grade_span_expectation attribute: gse_key'
  task :set_gse_keys, :roles => :db, :only => { :primary => true } do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:set_gse_keys --trace" 
  end

  desc 'find page_elements whithout owners and reclaim them'
  task :reclaim_page_elements, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:reclaim_elements --trace" 
  end
  
  desc 'transfer any Investigations owned by the anonymous user to the site admin user'
  task :transfer_investigations_owned_by_anonymous, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:transfer_investigations_owned_by_anonymous --trace"
  end
  
  desc 'deep set user ownership on all investigations'
  task :deep_set_user_on_all_investigations, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:run_deep_set_user_on_all_investigations --trace"
  end
  
  desc 'clean up teacher notes owned by the wrong user'
  task :clean_teacher_notes, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:clean_teacher_notes --trace"
  end

  desc 'add the author role to all users who have authored an Investigation'
  task :add_author_role_to_authors, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:add_author_role_to_authors --trace"
  end

  desc "set publication_status to 'draft' for all Investigations without publication_status"
  task :set_publication_status_to_draft, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:pub_status --trace"
  end

  desc "Data Collectors with a static graph_type to a static attribute; Embeddable::DataCollectors with a graph_type_id of nil to Sensor"
  task :data_collectors_with_invalid_graph_types, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:data_collectors_with_invalid_graph_types --trace"
  end

  desc "copy truncated Embeddable::Xhtml from Embeddable::Xhtml#content, Embeddable::OpenResponse and Embeddable::MultipleChoice#prompt into name"
  task :copy_truncated_xhtml_into_name, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:copy_truncated_xhtml_into_name --trace"
  end

  desc "create default Project from config/settings.yml"
  task :create_default_project_from_config_settings_yml, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:create_default_project_from_config_settings_yml --trace"
  end

  desc "generate date_str attributes from version_str for MavenJnlp::VersionedJnlpUrls"
  task :generate_date_str_for_versioned_jnlp_urls, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:generate_date_str_for_versioned_jnlp_urls --trace"
  end

  desc "Create bundle and console loggers for learners"
  task :create_bundle_and_console_loggers_for_learners, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:create_bundle_and_console_loggers_for_learners --trace"
  end

  # Tuesday, August 11, 2009
  
  desc "Find and report on invalid Dataservice::BundleContent objects"
  task :find_and_report_on_invalid_dataservice_bundle_content_objects, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:find_and_report_on_invalid_dataservice_bundle_content_objects --trace"
  end

  desc "Find and delete invalid Dataservice::BundleContent objects"
  task :find_and_delete_invalid_dataservice_bundle_content_objects, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:find_and_delete_invalid_dataservice_bundle_content_objects --trace"
  end

  desc "generate otml, valid_xml, and empty attributes for BundleContent objects"
  task :generate_otml_valid_xml_and_empty_attributes_for_bundle_content_objects, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:generate_otml_valid_xml_and_empty_attributes_for_bundle_content_objects --trace"
  end

  # Thursday October 8, 2009

  desc "Create default users, roles, district, school, course, and class, and greade_levels"
  task :default_users_roles, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:setup:default_users_roles --trace"
  end

  desc "Create default portal resources: district, school, course, and class, investigation and grades"
  task :default_portal_resources, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:setup:default_portal_resources --trace"
  end

  desc "Create districts and schools from NCES records for States listed in settings.yml"
  task :create_districts_and_schools_from_nces_data, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} portal:setup:create_districts_and_schools_from_nces_data --trace"
  end

  # Wed Dec 2nd
  desc "Convert Existing Clazzes so that multiple Teachers can own a clazz. (many to many change)"
  task :convert_clazzes_to_multi_teacher, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:convert_clazzes_to_multi_teacher --trace"
  end

  # Wed Dec 23nd, 2009
  desc "Delete_and_regenerate_maven_jnlp_resources"
  task :delete_and_regenerate_maven_jnlp_resources, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "ANSWER_YES=true rake RAILS_ENV=#{rails_env} rigse:jnlp:delete_and_regenerate_maven_jnlp_resources --trace"
  end

  # Wed Jan 6 2010
  desc "Fixup inner pages: add static_page associations (run deploy:migrate first!)"
  task :add_static_pages_to_inner_pages, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:add_static_page_to_inner_pages --trace"
  end
  
  # Feb 3, 2010
  desc "Extract and process learner responses from existing OTrunk bundles"
  task :extract_learner_responses_from_existing_bundles, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:extract_learner_responses_from_existing_bundles --trace"
  end

  desc "Erase all learner responses and reset the tables"
  task :erase_all_learner_responses_and_reset_the_tables, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:erase_all_learner_responses_and_reset_the_tables --trace"
  end
  
  #Feb 4, 2010
  desc "Convert all index-based MultipleChoice references in existing OTrunk bundles to local_id-based references."
  task :convert_choice_answers_to_local_ids, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:convert_choice_answers_to_local_ids --trace"
  end
  
  # seb: 20100513
  desc "Populate the new leaid, state, and zipcode portal district and school attributes with data from the NCES tables"
  task :populate_new_district_and_school_attributes_with_data_from_nces_tables, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:convert:populate_new_district_and_school_attributes_with_data_from_nces_tables --trace"
  end

  # seb: 20100513
  desc "Erase the marshalled jnlps stored in the jnlp object directory by the jnlp gem: config/jnlp_objects"
  task :empty_jnlp_object_cache, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:jnlp:empty_jnlp_object_cache --trace"
  end

  # seb: 20101019
  desc "Reset all activity position information"
  task :reset_activity_positions, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
      "rake RAILS_ENV=#{rails_env} rigse:fixup:reset_activity_positions --trace"
  end

  # seb: 20110126
  # See commit: Add "offerings_count" cache counter to runnables
  # https://github.com/stepheneb/rigse/commit/dadea520e3cda26a721e01428527a86222143c68
  desc "Recalculate the 'offerings_count' field for runnable objects"
  task :reset_offering_counts, :roles => :app do
    # remove investigation cache files
    run "rm -rf #{deploy_to}/#{current_dir}/public/investigations/*"
    run "cd #{deploy_to}/#{current_dir} && rake RAILS_ENV=#{rails_env} offerings:set_counts --trace"
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
    editor = YamlEditor.new('./config/installer.yml')
    editor.edit
    editor.write_file
    %x[rake build:installer:build_all ]
    
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

before 'deploy:restart', 'deploy:set_permissions'
before 'deploy:update_code', 'deploy:make_directory_structure'
after 'deploy:update_code', 'deploy:shared_symlinks'
after 'deploy:symlink', 'deploy:create_asset_packages'
after 'deploy:create_asset_packages', 'deploy:cleanup'
after 'installer:create', 'deploy:restart'
