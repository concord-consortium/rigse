Given /^the following page exists:$/ do |page_table|
  page_table.hashes.each do |hash|
    user_name = hash.delete('user')
    user = User.find_by_login user_name

    hash['user'] = user
    Factory :page, hash
  end
end

When /^I assign the page "([^"]*)" to the class "([^"]*)"$/ do |page_name, class_name|
  clazz = Portal::Clazz.find_by_name(class_name)
  page = Page.find_by_name(page_name)
  Factory.create(:portal_offering, {
    :runnable => page,
    :clazz => clazz
  })
end
