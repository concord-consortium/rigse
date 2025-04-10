require File.expand_path('../../spec_helper', __FILE__)
describe ImagesController do

  let(:user_id) {"1"}
  let(:image_params) {{
    "attribution" => "test attribution", "height" => "100", "image_content_type" => "image/png" ,
    "image_file_name" => "test.png", "image_file_size" => "1000", "license_code" => "MIT",
    "name" => "test image", "publication_status" => "published", "user_id" => user_id, "width" => "200"
  }}
  let(:non_empty_image) {{rails_5_cannot_send_empty_object: "yep, so adding this so test doesn't break"}}

  def mock_image(stubs={})
    @mock_image ||= mock_model(Image, stubs)
  end

  def stub_users_scope(results)
    mock_ar_set = double(:find => results)
    expect(Image).to receive(:visible_to_user_with_drafts).
      with(@logged_in_user).
        and_return(mock_ar_set)
  end

  before(:each) do
    @logged_in_user = login_author
  end


  describe "responding to GET index" do

    it "should expose an array of all the @images" do
      expect(Image).to receive(:search_list).and_return([mock_image])
      get :index, :format => :html
      expect(assigns[:images]).to eq([mock_image])
    end

  end

  describe "responding to GET show" do
    it "should expose the requested image as @image" do
      stub_users_scope(mock_image)
      get :show, params: { :id => "37" }
      expect(assigns[:image]).to equal(mock_image)
    end

  end
end
