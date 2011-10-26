require File.expand_path('../../../spec_helper', __FILE__)

describe "Portal::Offering" do
  it "return a jnlp with a main class of X" do
    generate_default_project_and_jnlps_with_factories
    learner = Factory(:full_portal_learner)
    user = learner.student.user
    user.register
    user.activate
    user.save!
    
    # log in as this learner
    visit "/"
    within("#project-signin") do
      fill_in("login", :with => user.login)
      fill_in("password", :with => 'password')
      click_button("Login")
    end
    
    visit portal_offering_path(:id => learner.offering.id, :format => :jnlp)
    xml = Nokogiri::XML(page.driver.response.body)
    main_class = xml.xpath("/jnlp/application-desc/@main-class")
    main_class.text.should == 'net.sf.sail.emf.launch.EMFLauncher2'
  end
end
