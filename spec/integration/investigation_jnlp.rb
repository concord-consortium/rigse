require File.expand_path('../../spec_helper', __FILE__)

describe "Investigation" do
  it "returns a valid jnlp file" do
    generate_default_project_and_jnlps_with_factories
    investigation = Factory(:investigation)

    visit investigation_path(:id => investigation.id, :format => :jnlp)
    xml = Nokogiri::XML(page.driver.response.body)
    jnlp_elements = xml.xpath("/jnlp")
    jnlp_elements.should_not be_empty
    main_class = xml.xpath("/jnlp/application-desc/@main-class")
    main_class.text.should == 'org.concord.LaunchJnlp'
  end
end
