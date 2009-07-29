require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin_projects/index.html.erb" do
  include Admin::ProjectsHelper

  before(:each) do
    assigns[:admin_projects] = [
      stub_model(Admin::Project,
        :name => "value for name",
        :url => "value for url",
        :states_and_provinces => "value for states_and_provinces",
        :maven_jnlp_server_id => 1,
        :maven_jnlp_family_id => 1,
        :jnlp_version => "value for jnlp_version",
        :snapshot_enabled => false
      ),
      stub_model(Admin::Project,
        :name => "value for name",
        :url => "value for url",
        :states_and_provinces => "value for states_and_provinces",
        :maven_jnlp_server_id => 1,
        :maven_jnlp_family_id => 1,
        :jnlp_version => "value for jnlp_version",
        :snapshot_enabled => false
      )
    ]
  end

  it "renders a list of admin_projects" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for url".to_s, 2)
    response.should have_tag("tr>td", "value for states_and_provinces".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for jnlp_version".to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
  end
end
