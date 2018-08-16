require File.expand_path('../../spec_helper', __FILE__)

describe "Investigation" do
  it "returns a valid jnlp file" do
    generate_default_settings_and_jnlps_with_factories
    investigation = Factory(:investigation)

    visit investigation_path(:id => investigation.id, :format => :jnlp)
    xml = Nokogiri::XML(page.driver.response.body)
    jnlp_elements = xml.xpath("/jnlp")
    expect(jnlp_elements).not_to be_empty
    main_class = xml.xpath("/jnlp/application-desc/@main-class")
    expect(main_class.text).to eq('org.concord.LaunchJnlp')
  end
end
