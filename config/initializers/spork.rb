#if defined?(Spork) && RAILS_ENV == 'test'
  #Spork.trap_class_method(Factory, :find_definitions)
  #class Rails::Initializer
    #def after_initialize_with_trap
      #Spork.trap_class_method(HasManyPolymorphs, :autoload)
      #after_initialize_without_trap
    #end
    #alias_method_chain :after_initialize, :trap
  #end
#end
