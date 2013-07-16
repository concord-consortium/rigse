Given /^the following external REST activity:$/ do |table|
  @external_activity = Factory.create(:external_activity, table.rows_hash)

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
  offering = Factory.create(:portal_offering, :runnable => @external_activity, :clazz => clazz)
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
  query_data["returnUrl"] = query_data["returnUrl"].sub(/888/,"#{@learner.id}")
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
  stub.should have_been_requested
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
  stub.should_not have_been_requested
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

When /^the browser returns the following data to the portal$/ do |string|
  login_as('student')
  path = external_activity_return_path(@learner)
  Delayed::Job.should_receive(:enqueue)
  page.driver.post(path, :content => string)
  # delayed_job doesn't work in tests, so force running the job
  Dataservice::ProcessExternalActivityDataJob.new(@learner.id, string).perform
end

Then /^the portal should create an open response saveable with the answer "([^"]*)"$/ do |answer|
  ors = Saveable::OpenResponse.all
  ors.count.should == 1
  ors.first.answer.should == answer
end

Then /^the portal should create an image question saveable with the answer "([^"]*)"$/ do |answer|
  iqs = Saveable::ImageQuestion.all
  iqs.count.should == 1
  a = iqs.first.answer
  a[:note].should == answer
  a[:blob].should_not be_nil
end


Then /^the portal should create a multiple choice saveable with the answer "([^"]*)"$/ do |answer|
  multiple_choices = Saveable::MultipleChoice.all
  matching = multiple_choices.select {|mcs| mcs.answer.first[:answer] == answer}
  matching.size.should >= 1
end

# Only test that the report_learner is upadted
# TODO: Test the actual report learner content
Then /the student's progress bars should be updated/ do
  @learner.reload
  @learner.report_learner.complete_percent.should be > 0.0
  @learner.report_learner.last_run.should_not be_nil
end
