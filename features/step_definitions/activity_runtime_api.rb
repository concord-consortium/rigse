Given /^the following external REST activity:$/ do |table|
  external_activity = Factory.create(:external_activity, table.rows_hash)
end

def get_request_stub(method, address)
  @request_stub_map ||= {}
  @request_stub_map[[method,address]]
end

def set_request_stub(method, address, stub)
  @request_stub_map ||= {}
  @request_stub_map[[method,address]] = stub
end

Given /^"([^"]*)" handles a (POST|GET) and responds with$/ do |address, method, response|
  method_symbol = method.downcase.to_sym
  stub = set_request_stub(method, address, stub_request(method_symbol, address))
  stub.to_return(response)
end

Then /^the (portal|browser) should send a (POST|GET) to "([^"]*)"$/ do |client,method,address|
  stub = get_request_stub(method, address)
  stub.should have_been_requested
end

def create_and_run_external_rest_activity(activity_name)
  activity = ExternalActivity.find_by_name activity_name
  clazz = Portal::Clazz.find_by_name("My Class")
  Factory.create(:portal_offering, :runnable => activity, :clazz => clazz)
  login_as('student')
  visit('/')
  within(".offering_for_student:contains('#{activity_name}')") do
    find(".solo.button").click
  end
end

Then /^the (portal|browser) should not send a (POST|GET) to "([^"]*)"$/ do |client, method, address|
  stub = get_request_stub(method, address)
  stub.should_not have_been_requested
end

When /^a student first runs the external activity "([^"]*)"$/ do |activity_name|
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