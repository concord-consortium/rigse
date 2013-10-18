require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper

describe InvestigationsController do
  before(:each) do
    @current_project = mock(
      :name => "test project",
      :using_custom_css? => false,
      :use_student_security_questions => false,
      :use_bitmap_snapshots? => false,
      :require_user_consent? => false)
    Admin::Project.stub!(:default_project).and_return(@current_project)
    controller.stub(:before_render) {
      response.template.stub(:net_logo_package_name).and_return("blah")
      response.template.stub_chain(:current_project).and_return(@current_project);
    }

    @admin_user = Factory.create(:user, { :email => "test@test.com", :password => "password", :password_confirmation => "password" })
    @admin_user.add_role("admin")

    login_admin

    @investigation = Factory.create(:investigation, {
      :name => "test investigation",
      :description => "new decription",
      :publication_status => "published"
    })
  end

  describe '#index' do
    let(:current_visitor)    { login_author }
    let(:investigation_page) { nil   }
    let(:grade_span)         { nil   }
    let(:search_term)        { nil   }
    let(:include_private)    { false }
    let(:expected_search_params) do
      {
        :material_types     => ["Investigation"],
        :investigation_page => investigation_page,
        :per_page           => 30,
        :private            => include_private,
        :grade_span         => grade_span,
        :search_term        => search_term,
        :user_id => current_visitor.id
      }
    end

    before(:each) do
      @double_search = double(Search)
      Search.stub!(:new).and_return(@double_search)
      @double_search.stub(:results => {
          Search::InvestigationMaterial => [@investigation],
          :all                          => [@investigation]
      })
    end

    context 'when the current user is an author' do
      it 'shows only public, official, and user-owned investigations' do
        # Expect the double to be called with certain params
        Search.should_receive(:new).with(expected_search_params).and_return(@double_search)
        get :index
        assigns[:investigations].length.should be(1) # Because that's what Search#results[:all] is stubbed to return
      end
    end

    context 'when the current user is an admin' do
      let(:include_private)  { true }
      let(:current_visitor)  { login_admin }
      it 'shows all investigations' do
        # Expect the double to be called with certain params
        Search.should_receive(:new).with(expected_search_params).and_return(@double_search)
        get :index
        assigns[:investigations].length.should be(1) # Because that's what Search#results[:all] is stubbed to return
      end

      context "when a search term is provided" do
        let(:search_term){ "filtered"}
        it 'filters investigations by keyword when provided' do
          # Expect the double to be called with certain params
          Search.should_receive(:new).with(expected_search_params).and_return(@double_search)
          get :index, { :name => 'filtered' }
          assigns[:investigations].length.should be(1) # Because that's what Search#results[:all] is stubbed to return
        end
      end

    end
  end

  describe '#duplicate' do
    it "should handle the duplicate method without error" do
      get :duplicate, :id => @investigation.id
    end
  end

  describe "Researcher Reports" do
    before(:each) do
      controller.should_receive(:send_data) { | data, options |
        options[:type].should == "application/vnd.ms.excel"
      }
      # this is needed to prevent a missing template call, the real send_data method
      # keeps rails from doing an implicit render, but since we are stubing send_data here
      # the implicit render isn't stopped
      controller.stub!(:render)
    end

    it 'should return an XLS file for the global Usage Report' do
      get :usage_report
    end

    it 'should return an XLS file for the global Details Report' do
      get :details_report
    end

    it 'should return an XLS file for the specific Usage Report' do
      get :usage_report, :id => @investigation.id
    end

    it 'should return an XLS file for the specific Details Report' do
      get :details_report, :id => @investigation.id
    end
  end

  describe "#show" do
    it "should handle the show method without error" do
      get :show, :id => @investigation.id
    end

    describe "with teacher mode='true'" do
      before(:each) do
        controller.stub!(:render)
        get :show, :id => @investigation.id, :teacher_mode => "true"
      end
      it "should assign true to teacher_mode instance var" do
        assert(assigns(:teacher_mode) == true)
      end
    end
    describe "with teacher mode='false'" do
      before(:each) do
        controller.stub!(:render)
        get :show, :id => @investigation.id, :teacher_mode => "false"
      end
      it "should assign false to teacher_mode instance var" do
        assert(assigns(:teacher_mode) == false)
      end
    end
  end
end
