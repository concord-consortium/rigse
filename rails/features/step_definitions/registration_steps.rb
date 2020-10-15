Then /^"([^"]*)" fields should have the class selector "([^"]*)"$/ do |error_count, selector|
  expect(page).to have_css(selector, :count => error_count.to_i)
end

Given /^there is an unactivated user named "([^"]*)"$/ do |login|
  @unactivated_user = FactoryBot.create(:user, :login => login)
  @unactivated_user.save!
  expect(@unactivated_user.state).to eql('pending')
end

Then /^I see the activation is complete$/ do
  expect(page).to have_xpath('.//*', :text => /Activation.*complete/)
end
