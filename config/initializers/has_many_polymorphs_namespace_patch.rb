# We have to override the autoload method since the default doesn't handle namespaces well...
module HasManyPolymorphs
  def self.autoload

    _logger_debug "autoload hook invoked"
    
    options[:requirements].each do |requirement|
      _logger_warn "forcing requirement load of #{requirement}"
      require requirement
    end
  
    Dir.glob(options[:file_pattern]).each do |filename|
      next if filename =~ /#{options[:file_exclusions].join("|")}/
      open filename do |file|
        if file.grep(/#{options[:methods].join("|")}/).any?
          begin
            file.rewind
            model = File.basename(filename)[0..-4].camelize
            class_regexp = /class\s+([^\s]+)\s+</
            line = file.grep(class_regexp).first
            if line =~ class_regexp  ## Should match unless no lines were found
              model = $1
            end
            _logger_warn "preloading parent model #{model}"
            model.constantize
          rescue Object => e
            _logger_warn "#{model} could not be preloaded: #{e.inspect}"
          end
        end
      end
    end
  end
end
