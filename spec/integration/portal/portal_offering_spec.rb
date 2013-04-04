require File.expand_path('../../../spec_helper', __FILE__)

describe "Portal::Offering" do
  before(:each) do
    generate_default_project_and_jnlps_with_factories
    @learner = Factory(:full_portal_learner)
    @user = @learner.student.user
    @user.save!
    @user.confirm!
    
    
    # log in as this learner
    visit "/"
    
    within("div.header-login-box") do
      fill_in("Username", :with => @user.login)
      fill_in("Password", :with => 'password')
      click_button("GO")
    end
  end

  it "returns a valid jnlp file" do
    visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)
    xml = Nokogiri::XML(page.driver.response.body)
    jnlp_elements = xml.xpath("/jnlp")
    jnlp_elements.should_not be_empty
    main_class = xml.xpath("/jnlp/application-desc/@main-class")
    main_class.text.should == 'org.concord.LaunchJnlp'
  end

  it "the jnlp argument points to a config file with a jnlp_session" do
    visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)
    xml = Nokogiri::XML(page.driver.response.body)
    jnlp_elements = xml.xpath("/jnlp")
    jnlp_elements.should_not be_empty
    argument = xml.xpath("/jnlp/application-desc/argument")[0]
    argument.text.should match 'config'
    argument.text.should match 'jnlp_session'
  end

  it "the config argument logs in the student" do
    visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)
    xml = Nokogiri::XML(page.driver.response.body)
    argument = xml.xpath("/jnlp/application-desc/argument")[0]

    page.reset!
    # make sure that worked by checking we are not logged in
    visit "/"
    page.should have_no_content "Welcome"

    # load in the config file
    visit argument
    visit "/"
    page.should have_content "Welcome #{@user.name}"
  end

  it "the config argument returns a valid config" do
    visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)
    jnlp_xml = Nokogiri::XML(page.driver.response.body)
    config_url = jnlp_xml.xpath("/jnlp/application-desc/argument")[0]

    page.reset!
    visit config_url
    config_xml = Nokogiri::XML(page.driver.response.body)
    puts config_xml
    puts page.driver.response.headers
  end
end
