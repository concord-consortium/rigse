require 'spec_helper'

describe "/home/home.html.haml" do
  let(:show_featured) { false }
  let(:show_signup) { false }
  let(:show_project_cards) { false }
  let(:content) { "" }

  before(:each) do
    power_user = stub_model(User, :has_role? => true)
    allow(view).to receive(:current_visitor).and_return(power_user)
    allow(view).to receive(:custom_content).and_return(content)
    allow(view).to receive(:show_featured).and_return(show_featured)
    allow(view).to receive(:show_signup).and_return(show_signup)
    allow(view).to receive(:show_project_cards).and_return(show_project_cards)
  end

  describe "when custom content is blank" do
    it "renders the project_info partial" do
      render
      expect(response).to render_template(partial: '_project_info')
    end

    it "renders the project_summary partial" do
      render
      expect(response).to render_template(partial: '_project_summary')
    end
  end

  describe "when there is custom content" do
    let(:content) { "custum-content-here" }

    it "Should render the custom content" do
      render
      expect(rendered).to match "custum-content-here"
    end

    it "should not render the project_info partial" do
      render
      expect(response).not_to render_template(partial: '_project_info')
    end

    it "should not render the project_summary partial" do
      render
      expect(response).not_to render_template(partial: '_project_summary')
    end
  end

  describe "with some themes" do
    let(:theme) { "learn" }
    before(:each) do
      expect(view).to receive(:theme_name).and_return(theme)
    end

    describe "with the default (learn) theme" do
      it "should include text from the learn project_info partial" do
        render
        expect(rendered).to match("About the STEM Resource Finder")
      end
      it "should include text from the learn project_summary partial" do
        render
        expect(rendered).to match("")
      end
    end

    describe "with the ngss theme" do
    end

  end
end
