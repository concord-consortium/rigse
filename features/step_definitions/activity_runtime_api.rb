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

Then /^the (portal|browser) should not send a (POST|GET) to "([^"]*)"$/ do |client, method, address|
  stub = get_request_stub(method, address)
  stub.should_not have_been_requested
end

When /^a student first runs the external activity "([^"]*)"$/ do |activity_name|
  activity = ExternalActivity.find_by_name activity_name
  clazz = Portal::Clazz.find_by_name("My Class")
  Factory.create(:portal_offering, :runnable => activity, :clazz => clazz)
  login_as('student')
  visit('/')
  within(".offering_for_student:contains('#{activity_name}')") do
    find(".solo.button").click
  end
end

Given /^a student has already run the external REST activity "([^"]*)" before$/ do |arg1|
  #pending # express the regexp above with the code you wish you had
end
