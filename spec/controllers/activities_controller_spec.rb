require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper

describe ActivitiesController do
  let (:activity) { Factory.create(:activity, :name => "test activity", :description => "new decription", :publication_status => "published") } 

  before(:each) do
    @admin_user = login_admin
  end

  describe '#index' do
    before(:each) do
      @double_search = double(Search)
      Search.stub!(:new).and_return(@double_search)
      @double_search.stub(:results => {:all => [activity]})
    end

    context 'when the user is an author' do
      before(:each) do
        @current_visitor = login_author
      end

      it 'shows only public, official, and user-owned activities' do
        # Expect the double to be called with certain params
        Search.should_receive(:new).with({ :material_types => [Activity], :page => nil, :private => true, :user_id => @current_visitor.id }).and_return(@double_search)
        get :index
        assigns[:activities].length.should be(1) # Because that's what Search#results[:all] is stubbed to return
      end
    end

    context 'when the user is an admin' do
      it 'shows all activities' do
        # Expect the double to be called with certain params
        Search.should_receive(:new).with({ :material_types => [Activity], :page => nil }).and_return(@double_search)
        get :index
        assigns[:activities].length.should be(1) # Because that's what Search#results[:all] is stubbed to return
      end

      it 'filters activities by keyword when provided' do
        # Expect the double to be called with certain params
        Search.should_receive(:new).with({ :material_types => [Activity], :page => nil, :search_term => 'filtered' }).and_return(@double_search)
        get :index, {:name => 'filtered'}
        assigns[:activities].length.should be(1) # Because that's what Search#results[:all] is stubbed to return
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
