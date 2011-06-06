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

#Table: | page   | multiple_choices |
Given /^the following pages with multiple choices exist:$/ do |page_table|
  page_table.hashes.each do |hash|
    page = Page.find_or_create_by_name(hash['page'])
    page.user = Factory(:user)
    page.save.should be_true
    mcs = hash['multiple_choices'].split(",").map{ |q| Embeddable::MultipleChoice.find_by_prompt(q.strip) }
    mcs.each do |q|
      q.pages << page
    end
    imgqs = hash['image_questions'].split(",").map{ |q| Embeddable::ImageQuestion.find_by_prompt(q.strip) }
    imgqs.each do |q|
      q.pages << page
    end
    page.save
  end
end
