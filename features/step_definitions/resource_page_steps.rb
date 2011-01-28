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

When /^I sort resource pages by "([^"]*)"$/ do |sort_str|
  visit "/resource_pages?sort_order=#{sort_str}"
end

When /^I show offerings count on the resource pages page$/ do 
  visit "/resource_pages?include_usage_count=true"
end

When /^I search for a resource page named "([^"]*)"$/ do |query|
  visit("/resource_pages?name=#{query}")
end

When /^I search for a resource page including drafts named "([^"]*)"$/ do |query|
  visit("/resource_pages?name=#{query}&include_drafts=true")
end

Given /^the teacher "([^"]*)" has (\d+) classes$/ do |teacher_login, num_classes|
  user = User.first(:conditions => { :login => teacher_login })
  teacher = user.portal_teacher
  num_classes.to_i.times do |n|
    clazz = Factory.create(:portal_clazz, :teacher => teacher)
  end
end

Given /^all resource pages are assigned to classes$/ do
  clazzes = Portal::Clazz.all
  ResourcePage.all.each do |resource_page|
    Factory.create(:portal_offering, {
      :runnable => resource_page,
      :clazz => clazzes.rand
    })
  end
end

When /^I assign the resource page "([^"]*)" to the class "([^"]*)"$/ do |page_name, class_name|
  clazz = Portal::Clazz.find_by_name(class_name)
  resource_page = ResourcePage.find_by_name(page_name)
  Factory.create(:portal_offering, {
    :runnable => resource_page,
    :clazz => clazz
  })
end

Then /^"([^"]*)" should have href like "([^"]*)"$/ do |link, href|
  a = page.find("a##{link}")
  a[:href].should =~ /#{href}/i
end

Then /^the link to "([^"]*)" should have a target "([^"]*)"$/ do |link, target|
  a = page.find("a##{link}")
  a[:target].should == target
end

Then /^"([^"]*)" should have href like "([^"]*)" with params "([^"]*)"$/ do |link, href, params|
  a = page.find("a##{link}")
  a[:href].should =~ /#{href}.*#{params}/i
end
