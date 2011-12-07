
require 'lib/local_names'
# Recursively converts the keys in a Hash to symbols.
# Also converts the keys in any Array elements which are 
# Hashes to symbols.
module HashExtensions
  def recursive_symbolize_keys
    inject({}) do |acc, (k,v)|
      key = String === k ? k.to_sym : k
      case v
      when Hash
        value = v.recursive_symbolize_keys
      when Array
        value = v.inject([]) do |arr, e|
          arr << (e.is_a?(Hash) ? e.recursive_symbolize_keys : e)
        end
      else
        value = v
      end
      acc[key] = value
      acc
    end
  end
end
Hash.send(:include, HashExtensions)


## to_hash_keys -- take from discussion: http://snippets.dzone.com/posts/show/302
## example [1,2,3].to_hash_keys{|e| "number #{e}!"}
## => {1 => "number 1!", 2 => "number 2!", 3 => "number 3!"}
module ArrayExtensions
  def to_hash_keys(&block)
    Hash[*self.collect { |v|
      [v, block.call(v)]
    }.flatten]
  end
end
Array.send(:include,ArrayExtensions)

# To enable selective supression of warnings from Ruby such as when
# redefining the constant: REST_AUTH_SITE_KEY when running spec tests
# See: http://mentalized.net/journal/2010/04/02/suppress_warnings_from_ruby/
# 
#   suppress_warnings { REST_AUTH_SITE_KEY = 'sitekeyforrunningtests' }
#
module Kernel
  def suppress_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    return result
  end
end

module StringExtensions
  def underscore_module
    gsub(/::|\//, '_').underscore
  end

  def delete_module(num=1)
    sub(/(.*?(::|\/)){0,#{num}}/, '')
  end
end
String.send(:include, StringExtensions)

module ActionView
  module Helpers
    module CaptureHelper
      def set_content_for(name, content = nil, &block)
        ivar = "@content_for_#{name}"
        instance_variable_set(ivar, nil)
        content_for(name, content, &block)
      end
    end
  end
end

module DeepCloneable
  module ClassMethods
    def default_uncloneable_attributes
      [:uuid, :id, :created_at, :updated_at]
    end
    def default_cloneable_options
      {:use_dictionary => true}
    end
  end
end

module ActiveRecord
  class Base
 
    def self.child_from_hash(field_name, child_hash, my_hash)
      association = reflect_on_association(field_name.to_sym )
      if association.options[:polymorphic]
        my_hash[association.options[:foreign_type]].constantize.from_hash child_hash
      else
        association.klass.from_hash child_hash
      end
    end
 
    def self.from_hash( hash )
      h = hash.dup
      h.each do |key,value|
        case value.class.to_s
        when 'Array'
          h[key].map! { |e| child_from_hash(key, e, h) }
        when /\AHash(WithIndifferentAccess)?\Z/
          h[key] = child_from_hash(key, value, h)
        end
      end
      create h
    end
 
    # The xml has a surrounding class tag (e.g. ship-to),
    # but the hash has no counterpart (e.g. 'ship_to' => {} )
    def self.from_xml( xml )
      from_hash begin
        Hash.from_xml(xml)[to_s.demodulize.underscore]
      rescue ; {} end
    end
 
  end # class Base
end # module ActiveRecord


# Sproutcore wants urls with fragment then query, whereas default URI ouputs query then fragment
module URI
  class Generic
    def to_sc
      str = ''
      if @scheme
        str << @scheme
        str << ':'
      end

      if @opaque
        str << @opaque

        if @fragment
          str << '#'
          str << @fragment
        end
      else
        if @registry
          str << @registry
        else
          if @host
            str << '//'
          end
          if self.userinfo
            str << self.userinfo
            str << '@'
          end
          if @host
            str << @host
          end
          if @port && @port != self.default_port
            str << ':'
            str << @port.to_s
          end
        end

        str << sc_path_query
      end

      str
    end

    def sc_path_query
      str = @path

      if @fragment
        str << '#'
        str << @fragment
      end

      if @query
        str += '?' + @query
      end
      str
    end

  end
end

# Define Object#dipsplay_name
# See:
#    lib/local_names.rb,
#    spec/libs/local_names_spec.rb,
#    spec/core_extensions/object_extensions_spec.rb
module DisplayNameMethod
  def display_name
    LocalNames.instance.local_name_for(self)
  end
end

# include #display_name everywhere
Object.send(:include, DisplayNameMethod)

