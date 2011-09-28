module SisImporter    
  class ImportLog < Logger
    attr_accessor :verbose
    attr_accessor :errors

    def initialize(base_directory,rotation)
      @log_directory   = base_directory
      @start_time      = Time.now
      @errors          = {:districts=> {}}
      @last_log_column = 0
      @step_counter = 0
      @verbose         = false
      @log_path        = File.join(@log_directory,"import_log.txt")
      @report_path     = File.join(@log_directory,"report.txt")
      @report          = Logger.new(@report_path,rotation)
      FileUtils.mkdir_p @log_directory
      super(@log_path,rotation)
      self.log_message("logging to #{@log_path}")
      self.log_message("reporting to #{@report_path}")
    end

    def log_message(message, options={})
      # optional formmating for short :log_level => :info messages
      #   print a continuing sequence of :info messages in 3 columns of 30 characters each
      #   :info_in_columns => ['teachers', 4, 30]
      #
      defaults = {:log_level => :debug, :newline => "\n", :info_in_columns => false}
      options = defaults.merge(options)
      newline = options[:newline]
      column_format = options[:info_in_columns]
      if column_format && (options[:log_level] == :info)
        message = sprintf("%-#{column_format[2]}s", message)
        @last_log_column += 1
        if @last_log_column == 1
          index = sprintf('%6d', @collection_index)
          length = sprintf('%-6s', "#{@collection_length}:")
          line_prefix = "#{column_format[0]} #{index}/#{length}"
          message = "#{line_prefix}  #{message}"
        end
        @last_log_column %= column_format[1]
        if @last_log_column == 0
          newline = "\n"
        else
          newline = ''
        end
      else
        if @last_log_column != 0
          message = "\n" + message
          @last_log_column = 0
        end
      end
      message = message + newline
      print message if verbose
      self.send(options[:log_level], message)
    end

    def status_update(step_size=1)
      if verbose
        @step_counter += 1
        if (@step_counter % step_size) == 0
          print '.' ; STDOUT.flush
        end
      end
    end

    def report(message)
      log_message(message, {:log_level => :error})
      @report.info(message)
    end
  end
end
