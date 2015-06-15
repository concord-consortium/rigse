Given(/^the following Interactive exist:$/) do |interactive_table|
  interactive_table.hashes.each do |hash|
    hash["user"] = User.find_by_login(hash[:user])
    Factory(:interactive, hash)
  end
end


Given(/^the following External Activity exist:$/) do |external_activity_table|
  external_activity_table.hashes.each do |hash|
    hash["user"] = User.find_by_login(hash[:user])
    Factory(:external_activity, hash)
  end
end


Given(/^I reindex interactive$/) do
   Interactive.solr_reindex
end

Given(/^I reindex external activity$/) do
   ExternalActivity.solr_reindex
end

When(/^I check "(.*?)" under Authorship$/) do |label|
  check("include_#{label}")
end

When(/^I uncheck "(.*?)" under Authorship$/) do |label|
  uncheck("include_#{label}")
end
