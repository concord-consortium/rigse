module SisImporter
  class FileTransport
    include Errors::Collector
    
    def initialize(opts)
      @opts = {}
      self.set_options(opts)
    end

    def set_options(opts)
      defaults.merge(opts).keys.each do |key|
        value = opts[key] || defaults[key]
        set_option(key,value)
      end
    end

    def defaults
      {
        :districts  => [],
        :output_dir => File.join('sis_import_data','districts'),
        :csv_files  => []
      }
    end

    def options(key=nil)
      if key
        return @opts[key]
      end
      return @opts
    end

    def set_option(key,value)
      @opts[key] = value
    end

    def output_dir
      return (options[:output_dir])
    end

    def csv_files
      return (options[:csv_files])
    end

    def local_path(file)
      File.join(output_dir,file)
    end

    def local_district_path(district)
      return File.join(local_path(district),timestamp)
    end

    def local_current_district_file(district,file)
      return File.join(local_current_district_path(district),file)
    end

    def local_current_district_path(district)
      return File.join(local_path(district),'current')
    end

    def timestamp
      @timestamp ||= Time.now.strftime("%Y%m%d_%H%M")
    end

    def initialize_paths(district)
      create_local_district_path(district)
      relink_local_current_district_path(district)
    end

    def create_local_district_path(district)
      FileUtils.mkdir_p(local_district_path(district))
    end

    # link <timestamp> => current
    def relink_local_current_district_path(district)
      FileUtils.rm_f(local_current_district_path(district))
      FileUtils.ln_s(local_district_path(district), local_current_district_path(district), :force => true)
    end

    def get_csv_files
      options[:districts].each do |district|
        initialize_paths(district)
        get_csv_files_for_district(district)
      end
    end

    def get_csv_files_for_district(district)
      logger.error("You should implement your own get_csv_file_for_district method")
    end

    def send_report(report,district)
      logger.error("You should implement your own get_csv_file_for_district method")
    end

    def shutdown
      logger.info("You should implement your own shutdown method")
    end

    def startup
      logger.info("You should implement your own startup method")
    end

    def logger
      return (options[:logger] ||= Logger.new(STDOUT))
    end
  end
end
