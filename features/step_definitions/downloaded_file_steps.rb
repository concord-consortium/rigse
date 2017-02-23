Then /^the jnlp should not be cached$/ do
  headers = page.driver.response.headers
  expect(headers).to have_key 'Pragma'
  # note: there could be multiple pragmas, I'm not sure how that will be returned and wether this will correclty match it
  expect(headers['Pragma']).to match "no-cache"
  expect(headers).to have_key 'Cache-Control'
  expect(headers['Cache-Control']).to match "max-age=0"
  expect(headers['Cache-Control']).to match "no-cache"
end

Then /^a jnlp file is downloaded$/ do
  headers = page.driver.response.headers
  expect(headers["Content-Type"]).to match "application/x-java-jnlp-file"

  @jnlp_xml = Nokogiri::XML(page.driver.response.body)

  # make sure a main_class attr is set
  main_class_attr = @jnlp_xml.xpath("/jnlp/application-desc/@main-class")
  expect(main_class_attr).not_to be_nil

end

def xml_text_or_nil(xpath_result)
  xpath_result.first.text unless xpath_result.blank?
end

def download_config(session)
  argument = @jnlp_xml.xpath("/jnlp/application-desc/argument")
  config_url = argument.text
  Capybara.session_name = session
  visit config_url
  headers = page.driver.response.headers
  expect(headers["Content-Type"]).to match "application/xml"

  @config_xml = Nokogiri::XML(page.driver.response.body)

  @config_otml_url = xml_text_or_nil @config_xml.xpath(
  	 "//void[@method='setProperty']/string[preceding-sibling::string[text()='sailotrunk.otmlurl']]"
  )

  @config_bundle_post_url = xml_text_or_nil @config_xml.xpath(
 	"//object[contains(@class,'PortfolioManagerService')]/void[@property='bundlePoster']/*/void[@property='postUrl']/string"
  )
end

Then /^the jnlp file for "([^"]+)" has a configuration for the student and offering$/ do |inv_name|
  download_config(:java_session)

  investigation = Investigation.find_by_name(inv_name)
  expect(@config_otml_url).to match %r{investigations/#{investigation.id}.*otml}

  # this is hack because of the seed data, this will only work if investigation is the first one assigned
  # in the seed data, to do it right we need the class name and we could assume the login is 'student'
  learner = Portal::Learner.first
  expect(@config_bundle_post_url).to match %r{bundle_loggers/#{learner.bundle_logger.id}.*bundle}  
end

Then /^the jnlp file for "([^"]+)" has a read-only configuration for the student and offering$/ do |inv_name|
  download_config(:java_session)

  investigation = Investigation.find_by_name(inv_name)
  expect(@config_otml_url).to match %r{investigations/#{investigation.id}.*otml}
  
  learner = Portal::Learner.first
  expect(@config_bundle_post_url).to be_nil
end

Then /^I simulate opening the jnlp a second time$/ do
  download_config(:java_session2)
end

Then /^I should see an error message in the Java application$/ do
  expect(@config_otml_url).to match /invalid/
end
