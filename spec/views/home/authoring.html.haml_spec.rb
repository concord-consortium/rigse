require File.expand_path('../../../spec_helper', __FILE__)

describe "home/authoring.html.haml" do
  before (:each) do
    @investigations  = [mock_model(Investigation, :id => 1, :name => "I1"),mock_model(Investigation, :id => 2, :name => "I2")]
    @resources_pages = [mock_model(ResourcePage, :id => 1, :name => "RP1", :display_name => 'RP1', :model_name => 'Resource Page'),mock_model(ResourcePage, :id => 2, :name => "RP2", :display_name => 'RP1', :model_name => 'Resource Page')]
    @resource_pages  = [mock_model(ResourcePage, :id => 1, :name => "RP1", :display_name => 'RP1', :model_name => 'Resource Page'),mock_model(ResourcePage, :id => 2, :name => "RP2", :display_name => 'RP1', :model_name => 'Resource Page')]
    @external_activities = [mock_model(ExternalActivity, :id => 1, :name => "RP1"),mock_model(ExternalActivity, :id => 2, :name => "RP2")]
    @interactives = [mock_model(Interactive, :id => 1, :name => "interactive1"),mock_model(ExternalActivity, :id => 2, :name => "interactive2")]
    @user = mock(
      :id => 1,
      :investigations  => @investigations,
      :resource_pages  => @resource_pages,
      :external_activities => @external_activities,
      :interactives =>@interactives,
      :has_role?       => true
    )

    view.stub!(:current_visitor).and_return(@user)
  end

  it "renders without error" do
    render
  end
end
