Then /I search for my own materials/ do
  search_mine_string = I18n.translate("search.only_mine")
  step "I should see \"#{search_mine_string}\""
end

When /^I wait for the search to be ready$/ do
  search_result_delay = ENV['SECONDS_BEFORE_TESTING_SEARCH_RESULTS'].presence || 3
  sleep(search_result_delay.to_i)
end
