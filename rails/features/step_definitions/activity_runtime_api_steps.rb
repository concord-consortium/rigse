Given /^the following external REST activity:$/ do |table|
  @external_activity = FactoryBot.create(:external_activity, table.rows_hash)

  # also create the mirrored activity template
  activity = Activity.create(:name => "#{@external_activity.name} Template")
  @external_activity.template = activity
  @external_activity.save

  section = activity.sections.create(:name => "#{@external_activity.name} Section")
  page = section.pages.create(:name => "#{@external_activity.name} Page")

  open_res = Embeddable::OpenResponse.create(:name => "Like", :prompt => "Do you like this activity?", :external_id => "1234567")
  page.add_embeddable(open_res)

  mc = Embeddable::MultipleChoice.create(:name => "Color", :prompt => "What color is the sky?", :external_id => "456789")
  mc.choices.create!(:choice => "red", :external_id => "97")
  mc.choices.create!(:choice => "blue", :external_id => "98")
  mc.choices.create!(:choice => "green", :external_id => "99")
  page.add_embeddable(mc)


  iq = Embeddable::ImageQuestion.create(
    :name => "Image Question",
    :prompt => "Draw a picture of the sky",
    :external_id => "1970")
  page.add_embeddable(iq)

  page.save

  clazz = Portal::Clazz.find_by_name("My Class")
  offering = FactoryBot.create(:portal_offering, :runnable => @external_activity, :clazz => clazz)
  @learner = offering.find_or_create_learner(User.find_by_login('student').portal_student)
end

def get_request_stub(method, address)
  @request_stub_map ||= {}
  @request_stub_map[[method,address]]
end

def set_request_stub(method, address, stub)
  @request_stub_map ||= {}
  @request_stub_map[[method,address]] = stub
end

Given /^"([^"]*)" handles a (POST|GET) with query:$/ do |address, method, table|
  query_data = table.rows_hash
  method_symbol = method.downcase.to_sym
  stub = get_request_stub(method, address)
  unless stub
    stub = set_request_stub(method, address, stub_request(method_symbol, address))
  end
  # must use a copy! Cucumber apparently doesn't re-allocate arguments for Background steps
  query_data["externalId"] = query_data["externalId"].sub(/999/,"#{@learner.id}")
  query_data["returnUrl"] = query_data["returnUrl"].sub(/site_url/,APP_CONFIG[:site_url])
  query_data["returnUrl"] = query_data["returnUrl"].sub(/key/,"#{@learner.secure_key}")

  query_data["resource_link_id"] = query_data["resource_link_id"].sub(/offering.id/,@learner.offering.id.to_s)
  # replace domain_uid by user id if it has the pattern "domain_uid of 'login'"
  if /domain_uid of '(.*)'/ =~ query_data["domain_uid"]
    query_data["domain_uid"] = User.find_by_login($~[1]).id.to_s
  end
  if /domain_uid of '(.*)'/ =~ query_data["platform_user_id"]
    query_data["platform_user_id"] = User.find_by_login($~[1]).id.to_s
  end
  if /site_url/ =~ query_data["platform_id"]
    query_data["platform_id"] = APP_CONFIG[:site_url]
  end
  if /class_info_url of '(.*)'/ =~ query_data["class_info_url"]
    query_data["class_info_url"] = Portal::Clazz.find_by_name($~[1]).class_info_url("http", "www.example.com")
  end
  if /class_hash of '(.*)'/ =~ query_data["class_hash"]
    query_data["class_hash"] = Portal::Clazz.find_by_name($~[1]).class_hash
  end
  if /class_hash of '(.*)'/ =~ query_data["context_id"]
    query_data["context_id"] = Portal::Clazz.find_by_name($~[1]).class_hash
  end
  stub.with(:query => query_data)
end

Given /^"([^"]*)" (?:handles a )?(POST|GET) (?:and )?responds with$/ do |address, method, response|
  method_symbol = method.downcase.to_sym
  stub = get_request_stub(method, address)
  unless stub
    stub = set_request_stub(method, address, stub_request(method_symbol, address))
  end
  stub.to_return(response)
end

Then /^the (portal|browser) should send a (POST|GET) to "([^"]*)"$/ do |client,method,address|
  stub = get_request_stub(method, address)
  expect(stub).to have_been_requested
end

def create_and_run_external_rest_activity(activity_name)
  login_as('student')
  visit('/')
  within(".offering_for_student:contains('#{activity_name}')") do
    find(".solo.button").click
  end
end

Then /^the (portal|browser) should not send a (POST|GET) to "([^"]*)"$/  do |client, method, address|
  stub = get_request_stub(method, address)
  expect(stub).not_to have_been_requested
end

When /^a student first runs the external activity "([^"]*)"$/  do |activity_name|
  create_and_run_external_rest_activity(activity_name)
end

Given /^the student ran the external REST activity "([^"]*)" before$/ do |activity_name|
  create_and_run_external_rest_activity(activity_name)
  WebMock::RequestRegistry.instance.reset!
end

When /^the student runs the external activity "([^"]*)" again$/ do |activity_name|
  login_as('student')
  visit('/')
  within(".offering_for_student:contains('#{activity_name}')") do
    find(".solo.button").click
  end
end
