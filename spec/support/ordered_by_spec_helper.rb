require 'delorean'
RSpec::Matchers.define :be_ordered_by do |attribute|
  match do |actual|
    result = true
    reverse_indicator = "_desc"
    attribute = attribute.to_s
    reverse = attribute =~ /#{reverse_indicator}/
    attribute = attribute.gsub(/#{reverse_indicator}/,'').to_sym
    if reverse
      sorted = actual.sort{ |a,b| b.send(attribute) <=> a.send(attribute)}
    else
      sorted = actual.sort{ |a,b| a.send(attribute) <=> b.send(attribute)}
    end
    sorted.each_with_index do |a,i|
      result = false unless actual[i] == a
    end
    result # return true or false for this matcher.
  end

  failure_message_for_should do |actual|
    "expected that #{actual.map {|i| i.send attribute}} would be sorted by #{attribute}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual.map {|i| i.send attribute}} would not be sorted by #{attribute}"
  end

  description do
    "be a sorted by #{attribute}"
  end
end

def collection_with_rand_mod_time(factory,count=10,opts={})
  count.times do
    Delorean.time_travel_to(rand(Date.parse('2011-01-01')..Date.parse('2012-12-01')))
    FactoryGirl.create(factory.to_sym, opts)
  end
  Delorean.back_to_the_present
end

# force the eval of a let expression for readability
def make(let_expression); end