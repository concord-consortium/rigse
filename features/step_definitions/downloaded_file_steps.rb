Then /^the jnlp should not be cached$/ do
  headers = page.driver.response.headers
  headers.should have_key 'Pragma'
  # note: there could be multiple pragmas, I'm not sure how that will be returned and wether this will correclty match it
  headers['Pragma'].should match "no-cache"
  headers.should have_key 'Cache-Control'
  headers['Cache-Control'].should match "max-age=0"
  headers['Cache-Control'].should match "no-cache"
end

Then /^a jnlp file is downloaded$/ do
  headers = page.driver.response.headers
  headers["Content-Type"].should match "application/x-java-jnlp-file"

  @jnlp_xml = Nokogiri::XML(page.driver.response.body)

  # make sure a main_class attr is set
  main_class_attr = @jnlp_xml.xpath("/jnlp/application-desc/@main-class")
  main_class_attr.should_not be_nil

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
  headers["Content-Type"].should match "application/xml"

  @config_xml = Nokogiri::XML(page.driver.response.body)

  @config_otml_url = xml_text_or_nil @config_xml.xpath(
  	 "//void[@method='setProperty']/string[preceding-sibling::string[text()='sailotrunk.otmlurl']]"
  )

  @config_bundle_post_url = xml_text_or_nil @config_xml.xpath(
 	"//object[contains(@class,'PortfolioManagerService')]/void[@property='bundlePoster']/*/void[@property='postUrl']/string"
  )
end

Then /^the jnlp file has a configuration for the student and offering$/ do
  download_config(:java_session)

  investigation = Investigation.first
  @config_otml_url.should match %r{investigations/#{investigation.id}.*otml}

  learner = Portal::Learner.first
  @config_bundle_post_url.should match %r{bundle_loggers/#{learner.bundle_logger.id}.*bundle}  
end

Then /^the jnlp file has a read-only configuration for the student and offering$/ do
  download_config(:java_session)

  investigation = Investigation.first
  @config_otml_url.should match %r{investigations/#{investigation.id}.*otml}

  learner = Portal::Learner.first
  @config_bundle_post_url.should be_nil
end

Then /^I simulate opening the jnlp a second time$/ do
  download_config(:java_session2)
end

Then /^I should see an error message in the Java application$/ do
  @config_otml_url.should match /invalid/
end
