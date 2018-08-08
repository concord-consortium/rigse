# require 'rspec/expectations'

module RunnablesLinkMatcher
  extend RSpec::Matchers::DSL

  matcher :be_link_like do |href, css_class, image, link_text|
    match do |actual|
      actual =~ /(.*)#{@href}(.*)#{@css_class}(.*)#{@image}(.*)(#{@link_text}(.*))?/i
    end
    failure_message_for_should { 'Expected a properly formed link.' }
    failure_message_for_should_not { 'Expected an improperly formed link.' }
  end
end
