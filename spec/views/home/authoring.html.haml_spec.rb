require File.expand_path('../../../spec_helper', __FILE__)

describe "home/authoring.html.haml" do
  before (:each) do
    @investigations  = [mock_model(Investigation, :name => "I1"),mock_model(Investigation, :name => "I2")]
    @resources_pages = [mock_model(ResourcePage, :name => "RP1"),mock_model(ResourcePage, :name => "RP2")]
    @resource_pages  = [mock_model(ResourcePage, :name => "RP1"),mock_model(ResourcePage, :name => "RP2")]
    @external_activities = [mock_model(ExternalActivity, :name => "RP1"),mock_model(ExternalActivity, :name => "RP2")]
    @user = mock(
      :investigations  => @investigations,
      :resource_pages  => @resource_pages,
      :external_activities => @external_activities,
      :has_role?       => true
    )

    view.stub!(:current_user).and_return(@user)
  end

  it "renders without error" do
    render
  end
end