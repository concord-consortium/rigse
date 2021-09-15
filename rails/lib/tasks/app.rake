namespace :app do

  desc "display info about the site admin user"
  task :display_site_admin => :environment do
    puts User.site_admin.to_yaml
  end

  namespace :setup do

    # require 'highline/import'
    autoload :Highline, 'highline'

    require 'fileutils'

    def rails_file_path(*args)
      File.join([::Rails.root.to_s] + args)
    end

    desc "add report service firebase app"
    task :add_report_service_firebase_app => :environment do
      # this separator stuff is so a multiline string can be pasted into
      # the highline ask command
      old_sep = $/
      $/ = "-----END PRIVATE KEY-----"
      private_key = ask("private_key: ")
      $/ = old_sep
      FirebaseApp.create(
        name: 'report-service-dev',
        client_email: 'report-service-dev@appspot.gserviceaccount.com',
        private_key: private_key
      )
    end

    desc "create default external reports and clients"
    task :create_default_external_reports => :environment do
      lara_domain = ENV['LARA_DOMAIN'].blank? ? 'app.lara.docker' : ENV['LARA_DOMAIN']
      lara_tool_id = ENV['LARA_TOOL_ID'].blank? ? "#{lara_domain}.#{ENV['USER']}" : ENV['LARA_TOOL_ID']

      auth_client = Client.where(name: "DEFAULT_REPORT_SERVICE_CLIENT").first_or_create(
        app_id: "DEFAULT_REPORT_SERVICE_CLIENT",
        app_secret: SecureRandom.uuid(),
        domain_matchers: ".*\.concord\.org localhost.*",
        client_type: "public"
      )

      ExternalReport.where(name: "DEFAULT_REPORT_SERVICE").first_or_create(
        url: "http://portal-report.concord.org/branch/master/index.html?sourceKey=#{lara_tool_id}",
        launch_text: "Report",
        client_id: auth_client.id,
        report_type: "offering",
        allowed_for_students: true,
        default_report_for_source_type: "LARA",
        individual_student_reportable: true,
        individual_activity_reportable: true,
        use_query_jwt: false
      )

      ExternalReport.where(name: "Class Dashboard").first_or_create(
        url: "http://portal-report.concord.org/branch/master/index.html?portal-dashboard&sourceKey=#{lara_tool_id}",
        launch_text: "Class Dashboard",
        client_id: auth_client.id,
        report_type: "offering",
        allowed_for_students: false,
        individual_student_reportable: false,
        individual_activity_reportable: false,
        use_query_jwt: false
      )

      ExternalReport.where(name: "AP Class Dashboard").first_or_create(
        url: "http://portal-report.concord.org/branch/master/index.html?portal-dashboard&sourceKey=#{lara_tool_id}&answersSourceKey=activity-player.concord.org",
        launch_text: "Class Dashboard",
        client_id: auth_client.id,
        report_type: "offering",
        allowed_for_students: false,
        individual_student_reportable: false,
        individual_activity_reportable: false,
        use_query_jwt: false
      )

      ExternalReport.where(name: "AP Report").first_or_create(
        url: "http://portal-report.concord.org/branch/master/index.html?sourceKey=#{lara_tool_id}&answersSourceKey=activity-player.concord.org",
        launch_text: "Report",
        client_id: auth_client.id,
        report_type: "offering",
        allowed_for_students: true,
        individual_student_reportable: true,
        individual_activity_reportable: false,
        use_query_jwt: false
      )

      # To support Activity Player publishing you need to manually add a Tool with the tool_id of https://activity-player.concord.org.
      # The convention is the source_type is ActivityPlayer.
    end

    task :local_setup => [:create_default_external_reports, :add_report_service_firebase_app, 'sso:add_dev_client']

    #######################################################################
    #
    # Raise an error unless the Rails.env is development,
    # unless the user REALLY wants to run in another mode.
    #
    #######################################################################
    desc "Raise an error unless the Rails.env is development"
    task :development_environment_only => :environment  do
      unless ::Rails.env == 'development'
        puts "\nNormally you will only be running this task in development mode.\n"
        puts "You are running in #{::Rails.env} mode.\n"
        unless HighLine.new.agree("Are you sure you want to do this?  (y/n) ")
          raise "task stopped by user"
        end
      end
    end
  end
end
