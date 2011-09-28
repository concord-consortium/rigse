# To run the import of the RITES districts:
#
#   RAILS_ENV=production ./script/runner "(SisImporter.new).run_scheduled_job"
#
# Here's an equivalent invocation in jruby:
#
#   RAILS_ENV=production jruby -J-Xmx2024m -J-server ./script/runner "SisImporter.new().run_scheduled_job"
#
# If you are doing development you will want to create a dump of the state of
# your working database before any imports have been made:
#
#    rake db:dump
#
# After testing the importer you can restore the database to it's previous state
# in order to run the importer again.
#
#    rake db:load
#
# Here are the default options:
#
#   :verbose => false
#   :skip_get_csv_files => false
#   :log_level => Logger::WARN
#   :districts => @sis_import_data_config[:districts]
#   :district_data_root_dir => "#{RAILS_ROOT}/sis_import_data/districts/#{@external_domain_suffix}/csv"
#
# You can customize the operation, here's an example:
#
#   If you want to:
#
#   - import data from just district "17", Lincoln
#   - skip reloading the csv files from the external SFTP server
#   - display a complete log on the console as you run the task
#   - create a log file that consists of ONLY the items recorded as :errors
#
#   SisImporter.new({:districts => ["17"], :skip_get_csv_files => true, :verbose => true, :log_level => Logger::ERROR})
#
# Here is the command I use to reload the production and development databases
# (on my development setup they are the same database) to the condition just after
# initial app creation and then test the importer in JRuby with data from Cranston.
#
#   rake db:load; RAILS_ENV=production jruby -J-Xmx2024m -J-server ./script/runner \
#   'SisImporter.new({:districts => ['07'], :verbose => true, :skip_get_csv_files => false}).run_scheduled_job'
#
# Note: In order to avoid issues with shell interpretation of characters in the command
# string passed to script/runner I use single-quotes around the command -- this then requires
# the use of an alternate string delimeter around: the district string: 07. I use double-quotes
# here but Ruby has additional string delimters if needed.

require 'fileutils'
require 'arrayfields'

module SisImporter
    class SisImporterError < ArgumentError
    end

    class MissingDistrictFolderError < Exception
      attr_accessor :folder
      def initialize(district_folder)
        self.folder = district_folder
      end
    end

  class SisImporter
    include SisCsvFields  # definitions for the fields we use when parsing.
    attr_reader   :parsed_data
    attr_accessor :log
    attr_accessor :file_transport
    attr_accessor :district_importers
    attr_accessor :reporter
    attr_accessor :sis_logger

    def initialize(options= {})
      User.delete_observers
      @sis_import_data_config = YAML.load_file("#{RAILS_ROOT}/config/sis_import_data.yml")[RAILS_ENV].symbolize_keys
      ExternalUserDomain.select_external_domain_by_server_url(@sis_import_data_config[:external_domain_url])
      @external_domain_suffix = ExternalUserDomain.external_domain_suffix

      defaults = {
        :verbose => false,
        :districts => @sis_import_data_config[:districts],
        :district_data_root_dir => "#{RAILS_ROOT}/sis_import_data/districts/#{@external_domain_suffix}/csv",
        :log_level => Logger::WARN,
        :drop_enrollments => false,
        :default_school => "Summer Courses 2011"
      }

      @sis_import_data_options = defaults.merge(options)
      @sis_import_data_options[:log_directory] ||= @sis_import_data_options[:district_data_root_dir]
      @verbose                = @sis_import_data_options[:verbose]
      @districts              = @sis_import_data_options[:districts]
      @district_data_root_dir = @sis_import_data_options[:district_data_root_dir]
      @log_directory          = @sis_import_data_options[:log_directory]

      @created_users          = []
      @updated_users          = []
      @error_users            = []
      
      @log                    = ImportLog.new(@log_directory,'daily')
      @log.level              = @sis_import_data_options[:log_level]
      @log.verbose            = @sis_import_data_options[:verbose]
      
      @reporter = Logger.new(@report_path,'daily')
      @reporter.level = Logger::INFO

      self.file_transport = SftpFileTransport.new({
        :csv_files => @csv_files,
        :districts => @districts,
        :host => @sis_import_data_config[:host], 
        :username => @sis_import_data_config[:username], 
        :password => @sis_import_data_config[:password],
        :output_dir => @district_data_root_dir,
        :logger   => @log
      })
      @log.log_message("Started in: #{@district_data_root_dir} at #{Time.now}")
      self.district_importers = []
    end

    def skip_get_csv_files
      return @sis_import_data_options[:skip_get_csv_files]
    end

    def get_csv_files
      @file_transport.get_csv_files
    end

    def run_scheduled_job(opts = {})
      # disable observable behavior on useres for import task

      @start_time = Time.now
      if skip_get_csv_files
        @log.log_message "\n (skipping: get csv files, using previously downloaded data ...)\n"
      else
        get_csv_files
      end

      num_districts = num_teachers = num_students = num_courses = num_classes = 0

      @districts.each do |district_name|
        # begin
          district = import_district(district_name)
          num_districts += 1
          num_teachers  += district.parsed_data[:staff].length
          num_students  += district.parsed_data[:students].length
          num_courses   += district.parsed_data[:courses].length
          num_classes   += district.parsed_data[:staff_assignments].length
        # rescue MissingDistrictFolderError => e
        #   @log.log_message "Could not find district folder for district #{district} in #{e.folder}", {:log_level => 'error'}
        # rescue RuntimeError => e
        #   @log.log_message "Runtime exception for district #{district}", {:log_level => 'error'}
        #   @log.log_message e.message, {:log_level => 'error'}
        #   @log.log_message e.backtrace.join("\n    "), {:log_level => 'debug'}
        # end
      end

      @end_time = Time.now
      report_grand_total(num_districts,num_teachers,num_students,num_courses,num_classes)
    end

    def import_district(district_name)
      opts = {
        :district               => district_name,
        :log                    => @log,
        :reporter               => @mereporter,
        :district_data_root_dir => @district_data_root_dir,
        :errors                 => @errors
      }
      district = DistrictImporter.new(opts)
      district.import
      self.district_importers << district
      district
    end

    def report_grand_total(num_districts,num_teachers,num_students,num_courses,num_classes)
      grand_total = <<-HEREDOC
      ============================
      Import Summary:
      ============================
      Start Time: #{@start_time.strftime("%Y-%m-%d %H:%M:%S")}
        End Time: #{@end_time.strftime("%Y-%m-%d %H:%M:%S")}
         Minutes: #{((@end_time - @start_time)/60).to_i}

       Districts: #{num_districts}
        Teachers: #{num_teachers}
        Students: #{num_students}
         Courses: #{num_courses}
         Classes: #{num_classes}

      ============================
      HEREDOC
      @log.report(grand_total)
    end
  end
end
