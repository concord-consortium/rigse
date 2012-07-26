# DeepCloning

module DeepCloning
  def self.included(base) #:nodoc:
    base.alias_method_chain :dup, :deep_cloning
    base.module_eval do
      @@no_dupes = false
      @@seen_source_objects = {}
      @@never_clone_attrs = []
      
      def already_seen?(obj)
        if @@no_dupes
          return @@seen_source_objects.has_key?("#{obj.class.name} - #{obj.id}")
        end
        return false
      end

      def record_object(obj, kopy)
        if @@no_dupes
          # puts "recording object: #{obj.class.name} - #{obj.id}"
          @@seen_source_objects["#{obj.class.name} - #{obj.id}"] = kopy
        end
        # puts "seen_source_objects is now: #{@@seen_source_objects.to_yaml}"
        # puts "returning #{kopy}"
        kopy
      end
      
      def get_stored_object(obj)
        @@seen_source_objects["#{obj.class.name} - #{obj.id}"]
      end

      def clone_object(obj, opts)
        if @@no_dupes && already_seen?(obj)
          # puts "Already seen object #{obj}."
          return get_stored_object(obj)
        end
        # puts "Haven't seen object #{obj}"
        return record_object(obj, obj.dup(opts))
      end
      
      def set_no_duplicates(b)
          # puts "dupe tracking changing: #{b}"
          @@seen_source_objects = {}
          if b
            # puts 'Skipping duplicates'
            @@no_dupes = true
          else
            # puts "Not skipping duplicates"
            @@no_dupes = false
          end
      end
      
      def set_never_clone(attrs)
        @@never_clone_attrs = attrs
      end
      
      def get_never_clone
        @@never_clone_attrs
      end
    end
  end

  # clones an ActiveRecord model. 
  # if passed the :include option, it will deep clone the given associations
  # if passed the :except option, it won't clone the given attributes
  #
  # === Usage:
  # 
  # ==== Cloning a model without an attribute
  #   pirate.clone :except => :name
  # 
  # ==== Cloning a model without multiple attributes
  #   pirate.clone :except => [:name, :nick_name]
  # ==== Cloning one single association
  #   pirate.clone :include => :mateys
  #
  # ==== Cloning multiple associations
  #   pirate.clone :include => [:mateys, :treasures]
  #
  # ==== Cloning really deep
  #   pirate.clone :include => {:treasures => :gold_pieces}
  #
  # ==== Cloning really deep with multiple associations
  #   pirate.clone :include => [:mateys, {:treasures => :gold_pieces}]
  # 
  def dup_with_deep_cloning options = {}
    kopy = dup_without_deep_cloning
    kopy.save(:validate => false) # skip validations when cloning
    
    if options[:except]
      Array(options[:except]).each do |attribute|
        dc_initialize_attribute kopy, attribute
      end
    end
    
    get_never_clone.each do |attribute|
      if kopy.query_attribute(attribute)
        dc_initialize_attribute kopy, attribute
      end
    end
    
    if options[:include]
      Array(options[:include]).each do |association, deep_associations|
        if (association.kind_of? Hash)
          deep_associations = association[association.keys.first]
          association = association.keys.first
        end
        opts = deep_associations.blank? ? {} : {:include => deep_associations}
        cloned_object = case self.class.reflect_on_association(association).macro
                        when :belongs_to, :has_one
                          self.send(association) && clone_object(self.send(association), opts)
                        when :has_many, :has_and_belongs_to_many
                          self.send(association).collect { |obj| clone_object(obj, opts) }
                        end
        # puts "cloned_object: #{cloned_object}"
        begin
          kopy.send("#{association}=", cloned_object)
        rescue ActiveRecord::RecordNotSaved
          logger.warn "failed to add object(s) to association: #{association}"
          logger.warn "  source object: #{self.inspect}"
          logger.warn "  object(s) added: #{cloned_object}"
          array_of_objects = [cloned_object].flatten
          logger.warn "  object(s) errors: #{array_of_objects.map{|obj| obj.errors.full_messages}}"
          raise
        end
      end
    end

    # force update of created_at, updated_at if defined
    t = Time.now
    kopy.send(:write_attribute, :created_at, t) if kopy.respond_to?(:created_at)
    kopy.send(:write_attribute, :updated_at, t) if kopy.respond_to?(:updated_at)

    kopy.save(:validate => false) # skip validations when cloning

    return kopy
  end
  
  def deep_clone(options={})
    set_no_duplicates(options[:no_duplicates])
    
    if options[:never_clone]
      set_never_clone(Array(options[:never_clone]))
    end
    
    ActiveRecord::Base.transaction do
      dup(options)
    end
  end
  
  # this was added to work around the fact that rails 3.2 removed the attributes_from_column_definition
  # method.  It seems this is pretty inefficient, but perhaps that doesn't matter
  def dc_initialize_attribute(kopy, attribute)
    default_value = self.class.initialize_attributes(self.class.column_defaults.dup)[attribute.to_s]
    kopy.send(:write_attribute, attribute, default_value)
  end
end
