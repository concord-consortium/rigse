require 'spec_helper'

describe "rendering application.html.haml" do
  let(:fake_visitor) { Factory(:user, {id: 101,}) }
  let(:roles) {['first-role']}

  before do
    view.stub(:current_visitor).and_return(fake_visitor)
    view.stub(:current_user).and_return(fake_visitor)
    view.stub(:calpicker_includes).and_return('')
    fake_visitor.stub(:authenticate).and_return(true)
    fake_visitor.stub(:role_names).and_return(roles)
  end

  it "applies the correct role classes" do
    assign(:original_user, fake_visitor)
    render(
      :text => "nothing",
      :layout => "layouts/application"
    )
    rendered.should have_selector("body.first-role-visitor")
  end
end

