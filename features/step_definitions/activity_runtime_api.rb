Given /^the following external REST activity:$/ do |table|
  external_activity = Factory.create(:external_activity, table.rows_hash)

  # also create the mirrored activity template
  activity = Activity.create(:name => "#{external_activity.name} Template")
  external_activity.template = activity
  external_activity.save

  section = activity.sections.create(:name => "#{external_activity.name} Section")
  page = section.pages.create(:name => "#{external_activity.name} Page")

  open_res = Embeddable::OpenResponse.create(:name => "Like", :prompt => "Do you like this activity?", :external_id => "1234567")
  page.add_embeddable(open_res)

  mc = Embeddable::MultipleChoice.create(:name => "Color", :prompt => "What color is the sky?", :external_id => "456789")
  mc.choices.create!(:choice => "red", :external_id => "97")
  mc.choices.create!(:choice => "blue", :external_id => "98")
  mc.choices.create!(:choice => "green", :external_id => "99")
  page.add_embeddable(mc)
  page.save
end

def get_request_stub(method, address)
  @request_stub_map ||= {}
  @request_stub_map[[method,address]]
end

def set_request_stub(method, address, stub)
  @request_stub_map ||= {}
  @request_stub_map[[method,address]] = stub
end

Given /^"([^"]*)" handles a (POST|GET) with body$/ do |address, method, body|
  method_symbol = method.downcase.to_sym
  stub = get_request_stub(method, address)
  unless stub
    stub = set_request_stub(method, address, stub_request(method_symbol, address))
  end
  if body =~ /^\/.*\/$/
    body = Regexp.new(body[1..-2])
  end
  stub.with(:body => body)
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
  stub.should have_been_requested
end

def create_and_run_external_rest_activity(activity_name)
  activity = ExternalActivity.find_by_name activity_name
  clazz = Portal::Clazz.find_by_name("My Class")
  @offering = Factory.create(:portal_offering, :runnable => activity, :clazz => clazz)
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

def current_learner
  @offering.find_or_create_learner(User.find_by_login('student').portal_student)
end

When /^the browser returns the following data to the portal$/ do |string|
  login_as('student')
  path = external_activity_return_path(current_learner)
  dr = page.driver
  Delayed::Job.should_receive(:enqueue)
  dr.post(path, string)
  # delayed_job doesn't work in tests, so force running the job
  Dataservice::ProcessExternalActivityDataJob.new(current_learner.id, string).perform
end

Then /^the portal should create an open response saveable with the answer "([^"]*)"$/ do |answer|
  ors = Saveable::OpenResponse.all
  ors.count.should == 1
  ors.first.answer.should == answer
end

Then /^the portal should create a multiple choice saveable with the answer "([^"]*)"$/ do |answer|
  mcs = Saveable::MultipleChoice.all
  mcs.count.should == 1
  mcs.first.answer.size.should == 1
  mcs.first.answer.first[:answer].should == answer
end
