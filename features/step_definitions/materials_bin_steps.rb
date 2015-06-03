Given /^the project "([^"]+)" has slug "([^"]+)" and ITSI bin$/ do |name, slug, page_cont|
  # Replace material collection names with IDs.
  page_cont.gsub!(/Collection \d/) { |name| MaterialsCollection.find_by_name(name).id }
  Factory.create(:project, name: name, landing_page_slug: slug, landing_page_content: page_cont)
end

Then /^category "([^"]+)" should be visible$/ do |category_name|
  page.has_css?('.mb-category', text: category_name, visible: true)
end

Then /^category "([^"]+)" with class "([^"]+)" should be visible$/ do |category_name, class_name|
  page.has_css?(".mb-category.#{class_name}", text: category_name, visible: true)
end

Then /^category "([^"]+)" should not be visible$/ do |category_name|
  page.has_css?('.mb-category', text: category_name, visible: false)
end

Then /^(\d+) materials should be visible$/ do |materials_count|
  page.has_css?('.mb-material', visible: true, count: materials_count)
end

Then /^"([^"]+)" material should be visible$/ do |material|
  page.has_css?('.mb-material', visible: true, text: material)
end

Then /^some materials should be visible$/ do
  page.has_css?('.mb-material', visible: true)
end

Then /^no materials should be visible$/ do
  page.has_no_css?('.mb-material', visible: true)
end

Then /^authors list should be visible$/ do
  page.has_css?('.mb-collection-name.mb-clickable', visible: true)
end

Then /^I click "([^"]+)" author name$/ do |author|
  find('.mb-collection-name.mb-clickable', visible: true, text: author).click
end

Then /^I click category "([^"]+)"$/ do |category_name|
  find('.mb-category', text: category_name, visible: true).click
end

Given /^user "([^"]+)" authored unofficial material "([^"]+)"$/ do |user_name, act_name|
  author = Factory.create(:confirmed_user, first_name: user_name, last_name: '')
  Factory.create(:external_activity, name: act_name, is_official: false, user: author)
end
