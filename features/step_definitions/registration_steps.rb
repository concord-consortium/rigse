Then /^"([^"]*)" fields should have the class selector "([^"]*)"$/ do |error_count, selector|
  page.should have_css(selector, :count => error_count.to_i)
end
