class LocalNames
  BaseTheme = 'default'
  attr_accessor :local_names
  attr_accessor :yaml_file
  attr_accessor :logger
  attr_accessor :theme_name


  # Lots of nay-saying about singleton patterns be-damned.
  class << self
    def instance(theme  = APP_CONFIG[:theme] || 'default')
      @instances = {} unless @instances
      unless @instances[theme]
        @instances[theme] = self.new(theme)
      end
      return @instances[theme]
    end
  end

  def initialize(theme  = APP_CONFIG[:theme] || 'default')
    self.theme_name = theme
    self.logger = Rails.logger
  end

  def load_names(path=File.join("config","local_names.yml"))
    self.yaml_file = File.join(RAILS_ROOT, path)
    config_data = []
    begin
      config_data = File.open(self.yaml_file, "r").read
      self.parse_yaml(config_data)
    rescue
      logger.warn("Can't read #{self.yaml_file}, no names defined");
    end
  end

  def parse_yaml(string)
    config = YAML::load(string)
    themes = [LocalNames::BaseTheme,theme_name]
    self.local_names = {}
    themes.each do |theme|
      names = config[theme]
      unless names
        logger.warn("No 'names' specified in #{self.yaml_file} for #{theme}")
        next
      end
      unless names.kind_of? Hash
        logger.warn("no entry for #{self.theme_name} specified as Hash in #{self.yaml_file}")
        next
      end
      self.local_names = self.local_names.merge(names)
    end
  end

  def local_name_for(thing,when_none=nil)
    load_names unless self.local_names
    # self.local_names ||= {}
    key = "default_key"
    computed_value = key
    case thing
    when Class
      key = thing.name
      computed_value = key.demodulize.underscore.humanize.titlecase
    when String
      # use the string itself as the key
      key = thing
      computed_value = key
    else
      # try to use the class name as the string
      key = thing.class.name
      computed_value = key.demodulize.underscore.humanize.titlecase
    end
    # Preffer to send the matching replacenet, followed by when_none, finally, just send key
    return self.local_names[key] || self.local_names[key.downcase] || when_none || computed_value
  end
end
