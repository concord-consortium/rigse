Given /^the following resource page[s]? exist[s]?:$/ do |table|
  table.hashes.each do |hash|
    user_name = hash.delete('user')
    user = User.first(:conditions => { :login => user_name })
    next if user.blank?

    hash['user'] = user
    resource_page = Factory(:resource_page, hash)
    resource_page.save!
  end
end

Given /^the resource page "([^"]*)" has an attachment named "([^"]*)"$/ do |resource_name, attachment_name|
  resource = ResourcePage.find_by_name resource_name
  resource.new_attached_files = {'name' => attachment_name, 'attachment' => File.new(::Rails.root.to_s + '/spec/fixtures/images/rails.png')}
  resource.save
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

When /^I open the accordion for the resource "([^"]*)"$/ do |resource_name|
  resource = ResourcePage.find_by_name resource_name
  selector = "#resource_page_toggle_resource_page_#{resource.id}"
  find(selector).click
end

When /^I follow "([^"]*)" for the resource page "([^"]*)"$/ do |link_name, resource_page_name|
  resource = ResourcePage.find_by_name resource_page_name
  with_scope("#resource_page_resource_page_#{resource.id}") do
    click_link(link_name)
  end
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
