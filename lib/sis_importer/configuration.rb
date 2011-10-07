module SisImporter
  class Configuration
    attr_accessor :configuration
    attr_accessor :transport
    attr_accessor :log
    def initialize(options= {})
      @configuration  = defaults.merge(self.yaml_config).merge(options)
      @transport     = @configuration[:transport_class].new(self) 
      self.log       = options[:log] || ImportLog.new(@configuration[:local_root_dir])
    end

    def defaults
      {
        :verbose                => false,
        :districts              => ['test'],
        :district               => 'test',
        :log_level              => Logger::INFO,
        :drop_enrollments       => false,
        :default_school         => "Summer Courses 2011",
        :external_domain_suffix => "sis_feed",
        :skip_get_csv_files     => false,
        :transport_class        => SisImporter::LocalFileTransport,
        :csv_files              => default_csv_files
      }
    end
    
    def config_file
      return File.join(RAILS_ROOT,'config','sis_import_data.yml')
    end

    def yaml_config(env=RAILS_ENV)
      YAML.load_file(config_file)[env].symbolize_keys
    end

    def method_missing(meth, *args, &block)
      if defined?(@configuration[meth.to_sym])
        @configuration[meth.to_sym]
      else
        super
      end
    end
    
    def respond_to?(meth)
      if defined?(@configuration[meth.to_sym])
        true
      else
        super
o     end
    end

    def default_csv_files
      %w{students staff courses enrollments staff_assignments }
    end

    def log_directory
      @configuration[:log_directory]  ||= local_root_dir
    end
  
    def local_root_dir
      @configuration[:local_root_dir] ||= default_local_root_dir
    end

    def default_local_root_dir
      external_domain_suffix = @configuration[:external_domain_suffix] || "default"
      begin
        ExternalUserDomain.select_external_domain_by_server_url(@configuration[:external_domain_url])
        external_domain_suffix = ExternalUserDomain.external_domain_suffix
      rescue
        # TODO: this is probably an error condition we should track
      end
      File.join(RAILS_ROOT, 'sis_import_data', 'districts', external_domain_suffix, 'csv')
    end
  end
end
