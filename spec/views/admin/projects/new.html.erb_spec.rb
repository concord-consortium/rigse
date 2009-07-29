require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin_projects/new.html.erb" do
  include Admin::ProjectsHelper

  before(:each) do
    assigns[:project] = stub_model(Admin::Project,
      :new_record? => true,
      :name => "value for name",
      :url => "value for url",
      :states_and_provinces => "value for states_and_provinces",
      :maven_jnlp_server_id => 1,
      :maven_jnlp_family_id => 1,
      :jnlp_version => "value for jnlp_version",
      :snapshot_enabled => false
    )
  end

  it "renders new project form" do
    render

    response.should have_tag("form[action=?][method=post]", admin_projects_path) do
      with_tag("input#project_name[name=?]", "project[name]")
      with_tag("input#project_url[name=?]", "project[url]")
      with_tag("textarea#project_states_and_provinces[name=?]", "project[states_and_provinces]")
      with_tag("input#project_maven_jnlp_server_id[name=?]", "project[maven_jnlp_server_id]")
      with_tag("input#project_maven_jnlp_family_id[name=?]", "project[maven_jnlp_family_id]")
      with_tag("input#project_jnlp_version[name=?]", "project[jnlp_version]")
      with_tag("input#project_snapshot_enabled[name=?]", "project[snapshot_enabled]")
    end
  end
end
