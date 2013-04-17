Given /^the following external REST activity:$/ do |table|
  # table is a Cucumber::Ast::Table
  # pending # express the regexp above with the code you wish you had
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

When /^a student first runs the external activity "([^"]*)"$/ do |arg1|
  #pending # express the regexp above with the code you wish you had
end

Given /^a student has already run the external REST activity "([^"]*)" before$/ do |arg1|
  #pending # express the regexp above with the code you wish you had
end
