require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin_projects/show.html.erb" do
  include Admin::ProjectsHelper
  before(:each) do
    assigns[:project] = @project = stub_model(Admin::Project,
      :name => "value for name",
      :url => "value for url",
      :states_and_provinces => "value for states_and_provinces",
      :maven_jnlp_server_id => 1,
      :maven_jnlp_family_id => 1,
      :jnlp_version => "value for jnlp_version",
      :snapshot_enabled => false
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ url/)
    response.should have_text(/value\ for\ states_and_provinces/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ jnlp_version/)
    response.should have_text(/false/)
  end
end
