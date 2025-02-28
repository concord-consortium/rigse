require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/images/show.html.haml" do

  before(:each) do
    @image = FactoryBot.create(:image)
    allow(@image.image).to receive(:variant).and_return(@image.image)
    allow(@image.image).to receive(:processed).and_return(@image.image)

    assigns[:image] = @image
    @user = double(
      :has_role?       => true,
      :anonymous?      => false
    )
    allow(view).to receive(:current_visitor).and_return(@user)
  end


  it "should render without error" do
    render
    expect(rendered).to match /my secret image/
  end
end
