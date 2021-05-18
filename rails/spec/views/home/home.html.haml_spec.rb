require File.expand_path('../../../spec_helper', __FILE__)

describe "/home/home.html.haml" do
  let(:show_featured) { false }
  let(:show_signup) { false }
  let(:show_project_cards) { false }
  let(:content) { "" }
  let(:view_options) {
    {
      custom_content: content,
      show_signup: show_signup,
      show_project_cards: show_project_cards,
      show_featured: show_featured
    }
  }

  it "renders without error" do
    render template: "home/home" , locals: view_options, layout: HomePage::LayoutNormal
  end

end
