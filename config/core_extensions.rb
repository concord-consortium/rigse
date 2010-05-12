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

# An extended group_by which will group at multiple depths
# Ex:
# >> ["aab","abc","aba","abd","aac","ada"].extended_group_by([lambda {|e| e.first}, lambda {|e| e.first(2)}])
# => {"a"=>{"aa"=>["aab", "aac"], "ab"=>["abc", "aba", "abd"], "ad"=>["ada"]}}
module Enumerable
  def extended_group_by(lambdas)
    lamb = lambdas.shift
    result = lamb ? self.group_by{|e| lamb.call(e)} : self
    if lambdas.size > 0
      final = {}
      temp = result.map{|k,v| {k => v.extended_group_by(lambdas.clone)}}
      temp.each {|r| final.merge!(r) }
      result = final
    end
    return result
  end
end

