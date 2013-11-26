require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper

describe ActivitiesController do
  let(:activity) { Factory.create(:activity, :name => "test activity", :description => "new decription", :publication_status => "published") }
  let(:current_visitor) { login_author }
  let(:user_id)         {current_visitor.id}
  let(:expect_private)  { false }
  let(:search_term)     { nil   }
  describe '#index' do
    # material browsing & searching is handled search_controller.rb
    # one idea: show only the current users list?
    it "should material indexes display anything?"
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
