
Given /^the following investigation exists:$/ do |investigation_table|
  investigation_table.hashes.each do |hash|
    user = User.first(:conditions => { :login => hash.delete('user') })
    hash[:user_id] = user.id
    investigation = Investigation.create(hash)
    activity =Activity.create(hash)
    section = Section.create(hash)
    page = Page.create(hash)
    section.pages << page
    activity.sections << section
    investigation.activities << activity
    investigation.save
  end
end

When /add a multiple choice question$/ do
  # pending # express the regexp above with the code you wish you had
end

When /^(?:|I )follow xpath "([^\"]*)"$/ do |xpath|
  find(:xpath, xpath).click
end

When /show the first page of the "(.*)" investigation$/ do |investigation_name|
  investigation = Investigation.find_by_name(investigation_name)
  page = investigation.pages.first
  visit page_path(page)
end

Given /a mock gse/ do
  domain = mock_model(RiGse::Domain,
    :id => 1,
    :name => "physics"
  )
  gse = mock_model(RiGse::GradeSpanExpectation,
    :domain => domain,
    :id => 1,
    :grade_span => '9-11',
    :print_summary_data => "summary data",
    :gse_key => 'PHY-9-11',
    :expectations => [] # not very ambitious
  )
  domain.stub(:grade_span_expectations).and_return([gse])

  RiGse::GradeSpanExpectation.stub!(:default).and_return(gse)
  RiGse::Domain.stub!(:find).and_return([domain])
  RiGse::Domain.stub!(:find).with(1).and_return(domain)
end

