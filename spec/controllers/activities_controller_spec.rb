require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper

describe ActivitiesController do
  let(:activity) { Factory.create(:activity, :name => "test activity", :description => "new decription", :publication_status => "published") }
  let(:current_visitor) { login_author }
  let(:user_id)         {current_visitor.id}
  let(:expect_private)  { false }
  let(:search_term)     { nil   }
  describe '#index' do
    let(:expected_params) do
      {
        :material_types=>[Search::ActivityMaterial],
        :activity_page => nil,
        :per_page      => 30,
        :user_id       => user_id,
        :grade_span    => nil,
        :private       => expect_private,
        :search_term   => search_term
    }
    end
    before(:each) do
      @double_search = double(Search)
      Search.stub!(:new).and_return(@double_search)
      @double_search.stub(:results => {Search::ActivityMaterial => [activity]})
    end

    context 'when the user is an author' do
      it 'shows only public, official, and user-owned activities' do
        # Expect the double to be called with certain params
        Search.should_receive(:new).with(expected_params).and_return(@double_search)
        get :index
        assigns[:activities].length.should be(1) # Because that's what Search#results[:all] is stubbed to return
      end
    end

    context 'when the user is an admin' do
      let(:current_visitor){ login_admin }
      let(:expect_private) { true }
      it 'shows all activities' do
        # Expect the double to be called with certain params
        Search.should_receive(:new).with(expected_params).and_return(@double_search)
        get :index
        assigns[:activities].length.should be(1) # Because that's what Search#results[:all] is stubbed to return
      end

      context "when a search term is provided" do
        let(:search_term) { 'filtered' }
        it 'filters activities by keyword when provided' do
          # Expect the double to be called with certain params
          Search.should_receive(:new).with(expected_params).and_return(@double_search)
          get :index, {:name => 'filtered'}
          assigns[:activities].length.should be(1) # Because that's what Search#results[:all] is stubbed to return
        end
      end


    end
  end

  describe "#show" do
    describe "with teacher mode='true'" do
      before(:each) do
        controller.stub!(:render)
        get :show, :id => activity.id, :teacher_mode => "true"
      end
      it "should assign true to teacher_mode instance var" do
        assert (assigns(:teacher_mode) == true)
      end
    end
    describe "with teacher mode='false'" do
      before(:each) do
        controller.stub!(:render)
        get :show, :id => activity.id, :teacher_mode => "false"
      end
      it "should assign true to teacher_mode instance var" do
        assert (assigns(:teacher_mode) == false)
      end
    end
  end
end
