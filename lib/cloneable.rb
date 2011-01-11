module Cloneable
  def self.included(base)
    base.class_eval do
      alias_method_chain :deep_clone, :defaults
    end
    base.extend(ClassMethods)
  end

  module ClassMethods
    def cloneable_associations(*args)
      @cloneable_associations ||= []
      @cloneable_associations += args
      @cloneable_associations
    end
  end

  def deep_clone_with_defaults(options = {})
    begin
      new_assocs = self.class.cloneable_associations
    rescue
      # Can't immagine how this would happen, but it would be hard to debug:
      throw("cloneable class #{self.class.name} fails #cloneable_associations {$!}")
    end
    if new_assocs.size > 0
      options[:include] ||= []
      if options[:include].kind_of? Hash
        options[:include] = Array(options[:include])
      end
      options[:include] += new_assocs
    end

    options[:use_dictionary] = true # prevent duplicates
    
    options[:except] ||= []
    options[:except] += [:uuid,:id,:updated_at,:created_at]
    # invokes on superclass (possibly up to Object#clone)
    deep_clone_without_defaults(options)
  end
end

class ActiveRecord::Base
  include Cloneable
end
