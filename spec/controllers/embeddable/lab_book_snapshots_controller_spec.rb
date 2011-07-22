require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::LabBookSnapshotsController do
  integrate_views
  it_should_behave_like 'an embeddable controller'
  before(:all) do
    generate_default_project_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
  end
  before(:each) do
    login_admin
    @mock_model = mock_model(Embeddable::LabBookSnapshot,
                            :target_element => nil,
                            :uuid => "12",
                            :name => "snapshot button")
  end

  def with_tags_like_an_otml_lab_book_snapshot
    # pass on this: Its required for 'an embeddable controller'
    # but we test the expected tags under multiple circumstances
    # seperately.
  end

  # OTLabbookButton useBitmap="true"
  # OTLabbookBundle scaleDrawTools="false"
  describe "with bitmap snapshots enabled" do 
    before(:each) do
      @mock_project.stub!(:use_bitmap_snapshots?).and_return(true)
    end
    it "the LabbookBundle should not scale drawTools" do
        Embeddable::LabBookSnapshot.should_receive(:find).with("37").and_return(@mock_model)
        get :show, :id => "37", :format => 'otml'
        response.should have_tag('OTLabbookBundle', :with => {:scaleDrawTools => 'false'})
    end
    it "the OTLabbookButton should useBitmaps" do
        Embeddable::LabBookSnapshot.should_receive(:find).with("37").and_return(@mock_model)
        get :show, :id => "37", :format => 'otml'
        response.should have_tag('OTLabbookButton', :with => {:useBitmap => 'true'})
    end
  end

  describe "with bitmap snapshots enabled" do 
    before(:each) do
      @mock_project.stub!(:use_bitmap_snapshots?).and_return(false)
    end
    it "the LabbookBundle should not scale drawTools" do
        Embeddable::LabBookSnapshot.should_receive(:find).with("37").and_return(@mock_model)
        get :show, :id => "37", :format => 'otml'
        response.should have_tag('OTLabbookBundle', :with => {:scaleDrawTools => 'true'})
    end
    it "the OTLabbookButton should useBitmaps" do
        Embeddable::LabBookSnapshot.should_receive(:find).with("37").and_return(@mock_model)
        get :show, :id => "37", :format => 'otml'
        response.should render_template(:show)
        response.should have_tag('OTLabbookButton', :with => {:useBitmap => 'false'})
    end
  end

end
