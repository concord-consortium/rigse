Given /^the following resource pages exist:$/ do |table|
  table.hashes.each do |hash|
    user_name = hash.delete('user')
    user = User.first(:conditions => { :login => user_name })
    next if user.blank?
    
    hash['user'] = user
    resource_page = Factory(:resource_page, hash)
    resource_page.save!
  end
end

When /^I search for a resource page named "([^"]*)"$/ do |query|
  visit("/resource_pages?name=#{query}")
end

When /^I search for a resource page including drafts named "([^"]*)"$/ do |query|
  visit("/resource_pages?name=#{query}&include_drafts=true")
end
