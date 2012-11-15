require File.expand_path('../../../spec_helper', __FILE__)

describe "Portal::Offering" do
  it "returns a valid jnlp file" do
    generate_default_project_and_jnlps_with_factories
    learner = Factory(:full_portal_learner)
    user = learner.student.user
    user.register
    user.activate
    user.save!
    
    # log in as this learner
    visit "/"
    within("#header-project-signin") do
      fill_in("Username", :with => user.login)
      fill_in("Password", :with => 'password')
      click_button("GO")
    end
    
    visit portal_offering_path(:id => learner.offering.id, :format => :jnlp)
    xml = Nokogiri::XML(page.driver.response.body)
    jnlp_elements = xml.xpath("/jnlp")
    jnlp_elements.should_not be_empty
    main_class = xml.xpath("/jnlp/application-desc/@main-class")
    main_class.text.should == 'org.concord.LaunchJnlp'
  end
end
