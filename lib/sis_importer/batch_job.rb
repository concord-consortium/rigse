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
#   :local_root_dir => "#{RAILS_ROOT}/sis_import_data/districts/#{@external_domain_suffix}/csv"
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

      @configuration.districts.each do |district_name|
        begin
          district = import_district(district_name)
        rescue Exception => e
          @log.error("Uncaught Exception: #{e.message}")
          @log.log_message(e.backtrace.join("\n"), {:log_level => 'error'})
          next
        end
        if district.completed
          num_districts += 1
          num_teachers  += district.parsed_data[:staff].length
          num_students  += district.parsed_data[:students].length
          num_courses   += district.parsed_data[:courses].length
          num_classes   += district.parsed_data[:staff_assignments].length
        else
          # tell some one
        end
      end

      @end_time = Time.now
      report_grand_total(num_districts,num_teachers,num_students,num_courses,num_classes)
    end

    def import_district(district_name)
      # TODO: these opts should be rolled into @configuration
      opts = {
        :district               => district_name,
        :log                    => @log,
        :configuration          => @configuration
      }
      district = DistrictImporter.new(opts)
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
