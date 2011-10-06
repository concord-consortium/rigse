module SisImporter
  class FileTransport
    include Errors::Collector
    
    def initialize(opts)
      @opts = {}
      self.set_options(opts)
      initialize_paths
    end

    def set_options(opts)
      defaults.merge(opts).keys.each do |key|
        value = opts[key] || defaults[key]
        set_option(key,value)
      end
    end

    def defaults
      {
        :district   => 'test',
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

    def district
      return (options[:district])
    end

    def local_path(file)
      File.join(output_dir,file)
    end
    
    def local_current_district_path
      return File.join(local_path(district),'current')
    end

    
    def local_district_path
      return File.join(local_path(district),timestamp)
    end

    def local_current_district_file(file)
      return File.join(local_current_district_path,file)
    end

    def local_current_report_file(filename)
      return File.join(local_current_district_path,'reports',filename)
    end

    def timestamp
      @timestamp ||= Time.now.strftime("%Y%m%d_%H%M")
    end

    def initialize_paths
      create_local_district_path
      relink_local_current_district_path
    end

    def create_local_district_path
      FileUtils.mkdir_p(local_district_path)
    end

    # link <timestamp> => current
    def relink_local_current_district_path
      FileUtils.rm_f(local_current_district_path)
      FileUtils.ln_s(local_district_path, local_current_district_path, :force => true)
    end

    def get_csv_files
      csv_files.each do |csv_file|
        filename = "#{csv_file}.csv"
        get_csv_file(filename)
      end
    end

    def get_csv_file(filename)
      logger.error("You should implement your own get_csv_file(filename) method")
    end

    def send_report(report_file)
      logger.error("You should implement your own send_report method")
    end

    def logger
      return (options[:logger] ||= Logger.new(STDOUT))
    end
  end
end
