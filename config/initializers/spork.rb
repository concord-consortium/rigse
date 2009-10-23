# Attempt to keep model access down when running spork.  I can't get this 
# to work in our setup tho.  - Noah Oct. 23
# see http://groups.google.com/group/sporkgem/browse_thread/thread/24e6342e6629d371/c37df459c6bf7fca?lnk=gst&q=has_many_polymorphs#c37df459c6bf7fca
# class Rails::Initializer
#   def after_initialize_with_trap
#     Spork.trap_class_method(HasManyPolymorphs, :autoload)
#     after_initialize_without_trap
#   end
#   alias_method_chain :after_initialize, :trap
# end 