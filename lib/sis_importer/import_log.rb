module SisImporter    
  class ImportLog < Logger
    attr_accessor :verbose
    attr_accessor :errors
    attr_accessor :log_path
    attr_accessor :report_path

    def initialize(base_directory,rotation='daily')
      @log_directory   = base_directory
      @start_time      = Time.now
      @errors          = {:districts=> {}}
      @last_log_column = 0
      @step_counter = 0
      @verbose         = false
      @log_path        = File.join(@log_directory,"import_log.txt")
      @report_path     = File.join(@log_directory,"report.txt")
      FileUtils.mkdir_p @log_directory
      FileUtils.mkdir_p @log_directory
      super(@log_path,rotation)

      @report          = Logger.new(@report_path,rotation)
      self.log_message("logging to #{@log_path}")
      self.log_message("reporting to #{@report_path}")
    end

    def with_info_in_columns(collection,heading="info",options={})
      message_width    = options[:message_width] || 8
      num_columns      = options[:num_columns]   || 5
      gutter_size      = options[:gutter_size]   || 3
      col_seperator    = sprintf("%-#{gutter_size}s", " ")
      row_seperator    = "\n"

      last_log_column  = 0
      collection_index = 0
      length           = sprintf('%-6s', "#{collection.length}:")
      message          = ""

      collection.each_with_index do |item,index|
        message = yield item
        if verbose
          message = sprintf("%-#{message_width}s", message)
          last_log_column += 1

          if last_log_column == 1
            index       = sprintf('%6d', index)
            line_prefix = "#{heading} #{index}/#{length}"
            message     = "#{line_prefix}  #{message}"
          end
          last_log_column %= num_columns

          if last_log_column == 0
            newline = row_seperator
          else
            newline = col_seperator
          end
          print message + newline
        end
      end
    end

    def log_message(message, options={})
      defaults = {:log_level => :debug, :newline => "\n", :info_in_columns => false}
      options = defaults.merge(options)
      message = message + options[:newline]
      print message if verbose
      self.send(options[:log_level], message)
    end

    def with_status_update(collection,step_size=1,character=".")
      collection.each_with_index do |item,index|
        yield item
        # if verbose
          if (index % step_size) == 0
            print character ; STDOUT.flush
          end
        # end
      end
    end

    def report(message)
      log_message(message, {:log_level => :error})
      @report.info(message)
    end
  end
end
