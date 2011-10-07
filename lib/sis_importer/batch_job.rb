# To run the import of the RITES districts:
#
#   RAILS_ENV=production ./script/runner "SisImporter::BatchJob.new(SisImporter::RemoteConfiguration.new()).run_scheduled_job"
#
# Here's an equivalent invocation in jruby:
#
#   RAILS_ENV=production jruby -J-Xmx2024m -J-server ./script/runner "SisImporter::BatchJob.new(SisImporter::RemoteConfiguration.new()).run_scheduled_job"
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
#
# You can customize the operation using a subclass of "SisImporter::Configuration"
# a RemoteConfiguration will pick up the district names from a remote FTP serevr.
#
#   If you want to:
#
#   - import data from just district "17", Lincoln
#   - skip reloading the csv files from the external SFTP server
#   - display a complete log on the console as you run the task
#   - create a log file that consists of ONLY the items recorded as :errors
#
#   config = SisImporter.Configuration new(:district => "17", :skip_get_csv_files => true, :verbose => true, :log_level => Logger::ERROR)
#   # then you can just use it like this:
#   SisImporter::BatchJob.new(config).run_scheduled_job


require 'fileutils'
require 'arrayfields'

module SisImporter
    class SisImporterError < ArgumentError
    end


  class BatchJob
    include SisCsvFields  # definitions for the fields we use when parsing.
    attr_accessor :log
    attr_accessor :districts
    attr_accessor :configuration

    def initialize(conf=SisImporter::Configuration.new({}))
      self.configuration      = conf

      @created_users          = []
      @updated_users          = []
      @error_users            = []
      
      @log                    = ImportLog.new(@configuration.log_directory,'daily')
      @log.level              = @configuration.log_level
      @log.verbose            = @configuration.verbose

      @log.log_message("Started in: #{@configuration.local_root_dir} at #{Time.now}")
      self.districts = []
    end

    def run_scheduled_job(opts = {})
      # disable observable behavior on useres for import task
      @start_time = Time.now

      # statistics:
      num_districts = num_teachers = num_students = num_courses = num_classes = 0
      
      districts = []
      if @configuration.in_progress?
        @log.error("Another process is running, aborting. ")
        return
      end

      districts = @configuration.districts
      return if districts.size < 1
      successes = []
      failures  = []
      @configuration.remove_old_signals
      @configuration.signal_in_progress
      districts.each do |district_name|
        begin
          district = import_district(district_name)
        rescue Exception => e
          @log.error("Uncaught Exception: #{e.message}")
          @log.log_message(e.message << "\n",      {:log_level => 'error'})
          @log.log_message(e.backtrace.join("\n"), {:log_level => 'error'})
          failures << district_name
          next
        end
        if district.completed
          num_districts += 1
          num_teachers  += district.parsed_data[:staff].length
          num_students  += district.parsed_data[:students].length
          num_courses   += district.parsed_data[:courses].length
          num_classes   += district.parsed_data[:staff_assignments].length
          successes << district_name
        else
          failures << district_name
          # tell some one
        end
      end

      @end_time = Time.now
      report_grand_total(num_districts,num_teachers,num_students,num_courses,num_classes)
      if failures.size > 0 
        @configuration.signal_failure(failures.split("\n"))
      end
      if successes.size > 0 
        @configuration.signal_success(successes.split("\n"))
      end
      @configuration.copy_logs(@log)
    end

    def import_district(district_name)
      # TODO: these opts should be rolled into @configuration
      configuration.configuration[:district] = district_name
      district = DistrictImporter.new(configuration)
      district.import
      self.districts << district
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
