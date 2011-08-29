# Load the rails application
require File.expand_path('../application', __FILE__)

JRUBY = defined? RUBY_ENGINE && RUBY_ENGINE == 'jruby'
# Initialize the rails application
RailsPortal::Application.initialize!

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

