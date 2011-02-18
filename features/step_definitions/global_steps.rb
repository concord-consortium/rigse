Given /^there are (\d+) (.+)$/ do |number, model_name|
  model_name = model_name.gsub(/\s/, '_').singularize
  the_class = model_name.classify.constantize

  the_class.destroy_all
  number.to_i.times do |i|
    Factory.create(model_name.to_sym)
  end
end

# Then the investigation named "Test" should have "offerings_count" equal to "1"
Then /^the (.*) named "([^"]*)" should have "([^"]*)" equal to "([^"]*)"$/ do |class_name, obj_name, field, value|
  obj = class_name.gsub(/\s/, "_").classify.constantize.find_by_name(obj_name)
  obj.send(field.to_sym).to_s.should == value
end

Then /"(.*)" should appear before "(.*)"/ do |first_item, second_item|
  page.body.should =~ /#{first_item}.*#{second_item}/m
end

When /^I debug$/ do
  debugger
end

When /^I wait "(.*)" seconds$/ do |seconds|
  sleep(seconds.to_i)
end
