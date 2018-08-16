# require 'rspec/expectations'

module RunnablesLinkMatcher
  extend RSpec::Matchers::DSL

  matcher :be_link_like do |href, css_class, image, link_text|
    match do |actual|
      actual =~ /(.*)#{@href}(.*)#{@css_class}(.*)#{@image}(.*)(#{@link_text}(.*))?/i
    end
    failure_message { 'Expected a properly formed link.' }
    failure_message_when_negated { 'Expected an improperly formed link.' }
  end
end
