rake db:drop
rake db:create
rake db:migrate
rake app:setup:default_users_roles
rake app:setup:create_additional_users
rake db:backup:load_probe_configurations
rake app:convert:assign_vernier_golink_to_users
rake app:jnlp:empty_jnlp_object_cache
rake app:jnlp:delete_and_regenerate_maven_jnlp_resources  #this is interactive

rake app:convert:create_default_project_from_config_settings_yml
rake app:import:create_itsi_prototype_data_collectors
rake app:import:force_create_itsi_activity_template

ssh -N -L 3355:localhost:3306 moleman.concord.org # this requires a password if you keys are setup right
rake --trace app:import:re_import_ccp_itsi_units_to_itsi_su

# need to run this to make grades and school
rake app:setup:default_portal_resources