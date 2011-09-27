require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::LabBookSnapshotsController do

  render_views

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_lab_book_snapshot
    assert_select('OTLabbookButton') do
      assert_select('target')
    end
  end

  describe "in addition a labbook snapshot controller" do

    before(:each) do
      generate_default_project_and_jnlps_with_mocks
      @mock_model = mock_model(Embeddable::LabBookSnapshot,
                              :target_element => nil,
                              :uuid => "12",
                              :name => "snapshot button")
    end
    
    describe "with bitmap snapshots enabled" do 
      before(:each) do
        @mock_project.stub!(:use_bitmap_snapshots?).and_return(true)
      end

      it "the LabbookBundle should not scale drawTools" do
        Embeddable::LabBookSnapshot.should_receive(:find).with("37").and_return(@mock_model)
        get :show, :id => "37", :format => 'otml'
        response.should render_template(:show)
        assert_select('OTSystem') do
          assert_select('bundles') do
            assert_select('OTLabbookBundle[scaleDrawTools="false"]')
          end
        end
      end

      it "the OTLabbookButton should useBitmaps" do
          Embeddable::LabBookSnapshot.should_receive(:find).with("37").and_return(@mock_model)
          get :show, :id => "37", :format => 'otml'
          response.should render_template(:show)
          assert_select('library') do
            assert_select('OTLabbookButton[useBitmap="true"]')
          end
      end
    end

    describe "with bitmap snapshots disabled" do 
      before(:each) do
        @mock_project.stub!(:use_bitmap_snapshots?).and_return(false)
      end

      it "the LabbookBundle should not scale drawTools" do
        Embeddable::LabBookSnapshot.should_receive(:find).with("37").and_return(@mock_model)
        get :show, :id => "37", :format => 'otml'
        response.should render_template(:show)
        assert_select('OTSystem') do
          assert_select('bundles') do
            assert_select('OTLabbookBundle[scaleDrawTools="true"]')
          end
        end
      end
      it "the OTLabbookButton should useBitmaps" do
          Embeddable::LabBookSnapshot.should_receive(:find).with("37").and_return(@mock_model)
          get :show, :id => "37", :format => 'otml'
          response.should render_template(:show)
          assert_select('library') do
            assert_select('OTLabbookButton[useBitmap="false"]')
          end
      end
    end

  end

end
