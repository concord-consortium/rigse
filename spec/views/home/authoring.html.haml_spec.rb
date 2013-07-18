require File.expand_path('../../../spec_helper', __FILE__)

describe "home/authoring.html.haml" do
  before (:each) do
    @investigations  = [mock_model(Investigation, :name => "I1"),mock_model(Investigation, :name => "I2")]
    @resources_pages = [mock_model(ResourcePage, :name => "RP1", :display_name => 'RP1', :model_name => 'Resource Page'),mock_model(ResourcePage, :name => "RP2", :display_name => 'RP1', :model_name => 'Resource Page')]
    @resource_pages  = [mock_model(ResourcePage, :name => "RP1", :display_name => 'RP1', :model_name => 'Resource Page'),mock_model(ResourcePage, :name => "RP2", :display_name => 'RP1', :model_name => 'Resource Page')]
    @external_activities = [mock_model(ExternalActivity, :name => "RP1"),mock_model(ExternalActivity, :name => "RP2")]
    @user = mock(
      :investigations  => @investigations,
      :resource_pages  => @resource_pages,
      :external_activities => @external_activities,
      :has_role?       => true
    )

    view.stub!(:current_visitor).and_return(@user)
  end

  it "renders without error" do
    render
  end
end