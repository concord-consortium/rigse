require File.expand_path('../../../spec_helper', __FILE__)

describe "Portal::Offering" do
  before(:each) do
    generate_default_settings_and_jnlps_with_factories
    @learner = Factory(:full_portal_learner)
    @user = @learner.student.user
    @user.save!
    @user.confirm!
    
    
    # log in as this learner
    visit "/"
    
    within("div.header-login-box") do
      fill_in("Username", :with => @user.login)
      fill_in("Password", :with => 'password')
      click_button("Log In")
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

  describe "the dynamic jnlp file" do
    it "should not be cached" do
      visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)

      headers = page.driver.response.headers
      headers.should have_key 'Pragma'
      # note: there could be multiple pragmas, I'm not sure how that will be returned and wether this will correclty match it
      headers['Pragma'].should match "no-cache"
      headers.should have_key 'Cache-Control'
      headers['Cache-Control'].should match "max-age=0"
      headers['Cache-Control'].should match "no-cache"
      headers['Cache-Control'].should match "no-store"
    end

    describe "whose jnlp argument" do
      it "points to a config file with a jnlp_session" do
        visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)
        jnlp_xml = Nokogiri::XML(page.driver.response.body)
        jnlp_elements = jnlp_xml.xpath("/jnlp")
        jnlp_elements.should_not be_empty
        argument = jnlp_xml.xpath("/jnlp/application-desc/argument")[0]
        argument.text.should match 'config'
        argument.text.should match 'jnlp_session'
      end

      it "logs in the student" do
        visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)
        jnlp_xml = Nokogiri::XML(page.driver.response.body)
        argument = jnlp_xml.xpath("/jnlp/application-desc/argument")[0]

        page.reset!
        # make sure that worked by checking we are not logged in
        visit "/"
        page.should have_no_content "Welcome"

        # load in the config file
        visit argument
        visit "/"
        page.should have_content "Welcome #{@user.name}"
      end

      it "returns a valid config that sets the correct session" do
        visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)
        jnlp_xml = Nokogiri::XML(page.driver.response.body)
        config_url = jnlp_xml.xpath("/jnlp/application-desc/argument")[0]
        page.reset!
        visit config_url
        config_xml = Nokogiri::XML(page.driver.response.body)
        cookie_service_node = config_xml.xpath("/java/object[@class='net.sf.sail.emf.launch.HttpCookieServiceImpl']")
        session_cookie_string = cookie_service_node.xpath("void/object/void/string/text()")[1].to_s
        config_session_id = session_cookie_string[/\=([^;]*);/, 1]
        header_session_string = page.driver.response.headers["Set-Cookie"]
        header_session_id = header_session_string[/#{Rails.application.config.session_options[:key]}\=([^;]*);/, 1]
        header_session_id.should == config_session_id
      end

      it "should not be cached" do
        visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)
        jnlp_xml = Nokogiri::XML(page.driver.response.body)
        config_url = jnlp_xml.xpath("/jnlp/application-desc/argument")[0]
        visit config_url
        headers = page.driver.response.headers
        headers.should have_key 'Pragma'
        # note: there could be multiple pragmas, I'm not sure how that will be returned and wether this will correclty match it
        headers['Pragma'].should match "no-cache"
        headers.should have_key 'Cache-Control'
        headers['Cache-Control'].should match "max-age=0"
        headers['Cache-Control'].should match "no-cache"
        headers['Cache-Control'].should match "no-store"
      end
    end
  end
end
