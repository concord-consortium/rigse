module Cloneable
#  def self.included(base)
#    base.class_eval do
#      @@cloneable_associations = []
#      def self.cloneable_associations
#        @@cloneable_associations
#      end
#
#      def self.include_in_clone(associations)
#        logger.info("including associations: '#{Array(associations).join("','")}'")
#        Array(associations).each do |a|
#          if (! @@cloneable_associations.include?(a))
#            @@cloneable_associations << a
#          end
#        end
#      end
#    end
#  end

  def clone(options)
    new_assocs = self.class.cloneable_associations
    # puts("new associations are: '#{new_assocs.join("','")}'")
    if new_assocs.size > 0
      options[:include] ||= []
      if options[:include].kind_of? Hash
        options[:include] = Array(options[:include])
      end
      options[:include] += new_assocs
    end
    # puts "Class is: #{self.class.name.to_s}"
    # puts(options.to_yaml)
    super(options)
  end

end