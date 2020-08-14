# Configure rails logging. Checks environment variable: RAILS_STDOUT_LOGGING
module LogConfig
  AVAILABLE_LOG_LEVELS = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN].freeze

  def self.configure(conf, level, default_level)
    conf.log_level = AVAILABLE_LOG_LEVELS[0] # most verbose by default
    if AVAILABLE_LOG_LEVELS.include? default_level
      conf.log_level = default_level
    end
    conf.log_level = level if AVAILABLE_LOG_LEVELS.include? level
    # Disable logging to file. It might have performance impact while using
    # Docker for Mac (slow filesystem sync).
    if BoolENV['RAILS_STDOUT_LOGGING']
      conf.logger = Logger.new(STDOUT)
      conf.logger.level = conf.log_level
    end
  end
end
