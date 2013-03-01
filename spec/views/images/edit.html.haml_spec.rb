require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/images/edit.html.haml" do

  before(:each) do
    @time = Time.now
    assigns[:image] = @image = stub_model(Image,
      id: 3,
      user_id: 12,
      name: 'test name',
      attribution: 'test attribution',
      publication_status: 'public',
      created_at: @time, updated_at: @time,
      image_file_name: 'filename',
      image_content_type: 'jpg',
      image_file_size: 200,
      image_updated_at: @time,
      license_code: 'CC-BY',
      width: 10,
      height: 20
    )
    @user = mock(
      :has_role?       => true
    )

    view.stub!(:current_user).and_return(@user)
  end

  it "should render edit form without error" do
    render
  end
end


