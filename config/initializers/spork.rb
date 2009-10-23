if defined?(Spork)
  Spork.trap_class_method(Factory, :find_definitions)
end