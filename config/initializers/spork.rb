if defined?(Spork) && RAILS_ENV == 'test'
  Spork.trap_class_method(Factory, :find_definitions)
end