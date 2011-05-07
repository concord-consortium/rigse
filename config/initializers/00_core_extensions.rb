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
      new h
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

