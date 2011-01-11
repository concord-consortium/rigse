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

require 'cloneable'
