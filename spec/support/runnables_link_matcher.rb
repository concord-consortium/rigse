require 'rspec/expectations'

RSpec::Matchers.define :be_link_like do |href, css_class, image, link_text=""|
  match do |actual|
    actual =~ /(.*)#{href}(.*)#{css_class}(.*)#{image}(.*)(#{link_text}(.*))?/i
  end
  failure_message do |actual|
    "Expected a properly formed link."
  end
  failure_message_when_negated do |actual|
    "Expected an improperly formed link."
  end
end
