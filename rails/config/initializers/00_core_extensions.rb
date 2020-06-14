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
#    spec/core_extensions/object_extensions_spec.rb
module DisplayNameMethod
  def display_name
    if self.respond_to? :model_name  # model_name only works for AR
      self.model_name.human.titlecase
    else
      self.class.name.humanize.titlecase
    end
  end
end

# include #display_name everywhere
Object.send(:include, ::DisplayNameMethod)


module Enumerable
  # An extended group_by which will group at multiple depths
  # Ex:
  # >> ["aab","abc","aba","abd","aac","ada"].extended_group_by([lambda {|e| e.first}, lambda {|e| e.first(2)}])
  # => {"a"=>{"aa"=>["aab", "aac"], "ab"=>["abc", "aba", "abd"], "ad"=>["ada"]}}

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

