require File.expand_path('../../../spec_helper', __FILE__)

describe "Portal::Offering" do
  before(:each) do
    generate_default_settings_and_jnlps_with_factories
    @learner = Factory(:full_portal_learner)
    @user = @learner.student.user
    @user.save!
    @user.confirm!

    #
    # log in as this learner (this URL will render login form for non-logged
    # in user)
    #
    visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)

    #
    # This still uses the login form on /portal/offerings/[id].jnlp
    # as this page is not styled to use
    # portal-pages header.
    #
    within("form[@id='login-form']") do
      fill_in("username", :with => @user.login)
      fill_in("password", :with => 'password')
      click_button("Log In")
    end

  end

  it "returns a valid jnlp file" do
    path = portal_offering_path(:id => @learner.offering.id, :format => :jnlp)
    visit path
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

    end
  end
end
