require 'spec_helper'

RegexForAuthFailShow = /can not view the requested resource/
RegexForAuthFailNew = /can not create the requested resource/
RegexForAuthFailModify = /can not update the requested resource/

describe Admin::CohortsController do
  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
    @cohort_1 = FactoryBot.create(:admin_cohort, name: 'cohort 1', project: project_1)
    @cohort_2 = FactoryBot.create(:admin_cohort, name: 'cohort 2', project: project_2)
    @cohort_3 = FactoryBot.create(:admin_cohort, name: 'cohort 3', project: project_3)
  end

  let(:project_1) { FactoryBot.create(:admin_project, name: 'project_1') }
  let(:project_2) { FactoryBot.create(:admin_project, name: 'project_2') }
  let(:project_3) { FactoryBot.create(:admin_project, name: 'project_3') }

  let(:admin_user) { FactoryBot.generate(:admin_user) }
  let(:user) { FactoryBot.create(:user) }

  describe 'A user not affiliated with a project' do
    describe 'GET index' do
      it 'wont see any cohorts' do
        get :index
        expect(assigns[:admin_cohorts]).to eq([])
      end
    end

    describe 'Show' do
      it 'wont let them see any cohorts' do
        [@cohort_1,@cohort_2,@cohort_3].each do |cohort|
          get :show, id: cohort.id
          # Redirect, and show error when not allowed:
          expect(response).to have_http_status(:redirect)
          expect(request.flash[:alert]).to match(RegexForAuthFailShow)
        end
      end
    end

    describe 'New' do
      it 'it wont let them create a new cohort' do
        get :new
        # Redirect, and show error when not allowed:
        expect(response).to have_http_status(:redirect)
        expect(request.flash[:alert]).to match(RegexForAuthFailNew)
      end
    end

    describe 'create' do
      it 'it wont let them create a new cohort' do
        put :create
        # Redirect, and show error when not allowed:
        expect(response).to have_http_status(:redirect)
        expect(request.flash[:alert]).to match(RegexForAuthFailNew)
      end
    end

    describe 'update' do
      it 'it wont let them update an existing cohort' do
        put :update, id:@cohort_1.id
        # Redirect, and show error when not allowed:
        expect(response).to have_http_status(:redirect)
        expect(request.flash[:alert]).to match(RegexForAuthFailModify)
      end
    end
  end

  describe 'A user who is an admin for project 2' do
    before(:each) do
      user.add_role_for_project('admin', project_2)
    end

    describe 'GET index' do
      it 'can only see cohort 2' do
        get :index
        expect(assigns[:admin_cohorts]).not_to include(@cohort_1)
        expect(assigns[:admin_cohorts]).to include(@cohort_2)
        expect(assigns[:admin_cohorts]).not_to include(@cohort_3)
      end
    end
  end

  describe 'A user who is an admin for project 1' do
    before(:each) do
      user.add_role_for_project('admin', project_1)
    end

    describe 'GET index' do
      it 'can only see cohort 1' do
        get :index
        expect(assigns[:admin_cohorts]).to include(@cohort_1)
        expect(assigns[:admin_cohorts]).not_to include(@cohort_2)
        expect(assigns[:admin_cohorts]).not_to include(@cohort_3)
      end
    end

    describe 'Show' do
      describe 'Cohort 1 (user IS a project admin)' do
        it 'lets them see it' do
          get :show, id:@cohort_1.id
          expect(assigns[:admin_cohort]).to eq(@cohort_1)
          expect(response).to have_http_status(:ok)
        end
      end
      describe 'Cohort 2 (user is NOT a project admin)' do
        it 'wont let them see it' do
          get :show, id:@cohort_2.id
          # Redirect, and show error when not allowed:
          expect(response).to have_http_status(:redirect)
          expect(request.flash[:alert]).to match(RegexForAuthFailShow)
        end
      end
    end

    describe 'New' do
      it 'it should show the New form' do
        expect(get :new).to render_template('new')
        # Redirect, and show error when not allowed:
      end
      it 'should display only the projects for which the user is an admin' do
        get :new
        expect(assigns(:projects)).to include(project_1)
        expect(assigns(:projects)).not_to include(project_2)
        expect(assigns(:projects)).not_to include(project_3)
      end
      it 'should return an OK http status' do
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'Edit' do
      before(:each) do
        allow(Admin::Cohort).to receive(:find).and_return(@cohort1)
      end
      it 'it should show the Edit form' do
        expect(get :edit).to render_template('edit')
        # Redirect, and show error when not allowed:
      end
      it 'should display only the projects for which the user is an admin' do
        get :edit
        expect(assigns(:projects)).to include(project_1)
        expect(assigns(:projects)).not_to include(project_2)
        expect(assigns(:projects)).not_to include(project_3)
      end
      it 'should return an OK http status' do
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'Create' do
      let(:params) do
        {
          admin_cohort: {
            project_id: project_id,
            name: 'name'
          }
        }
      end
      describe 'when creating a cohort for project 1 which they ARE admin for' do
        let(:project_id) { project_1.id }
        it 'it SHOULD let them' do
          post :create, params
          cohort = assigns(:admin_cohort)
          expect(assigns(:admin_cohort)).to be_valid
          expect(response).to redirect_to(admin_cohort_path(cohort))
        end
      end

      describe 'when creating a cohort for project 2 (NOT their project)' do
        let(:project_id) { project_2.id }
        it 'it should NOT let them' do
          post :create, params
          # Redirect, and show error when not allowed:
          expect(response).to have_http_status(:redirect)
          expect(request.flash[:alert]).to match(RegexForAuthFailNew)
        end
      end
    end

  end


  describe 'A site admin' do
    let(:user) { admin_user }

    describe 'GET index' do
      it 'can see all of the cohorts in the index' do
        get :index
        expect(assigns[:admin_cohorts]).to include(@cohort_1)
        expect(assigns[:admin_cohorts]).to include(@cohort_2)
        expect(assigns[:admin_cohorts]).to include(@cohort_3)
      end
    end

    describe 'Show' do
      describe 'Cohort 1' do
        it 'can see it' do
          get :show, id: @cohort_1.id
          expect(assigns[:admin_cohort]).to eq(@cohort_1)
          expect(response).to have_http_status(:ok)
        end
      end
      describe 'Cohort 2' do
        it 'can see it' do
          get :show, id: @cohort_2.id
          expect(assigns[:admin_cohort]).to eq(@cohort_2)
          expect(response).to have_http_status(:ok)
        end
      end
    end

    describe 'New' do
      it 'it should show the New form' do
        expect(get :new).to render_template('new')
        # Redirect, and show error when not allowed:
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'Create' do
      let(:params) do
        {
          admin_cohort: {
            project_id: project_id,
            name: 'name'
          }
        }
      end
      describe 'for a cohort in project 1' do
        let(:project_id) { project_1.id }
        it 'it SHOULD let them create a new cohort' do
          post :create, params
          cohort = assigns(:admin_cohort)
          expect(assigns(:admin_cohort)).to be_valid
          expect(response).to redirect_to(admin_cohort_path(cohort))
        end
      end


    describe 'New' do
      it 'it should show the New form' do
        expect(get :new).to render_template('new')
        # Redirect, and show error when not allowed:
      end
      it 'should display all the projects in the project dropdown' do
        get :new
        expect(assigns(:projects)).to include(project_1)
        expect(assigns(:projects)).to include(project_2)
        expect(assigns(:projects)).to include(project_3)
      end
      it 'should return an OK http status' do
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'Edit' do
      before(:each) do
        allow(Admin::Cohort).to receive(:find).and_return(@cohort1)
      end
      it 'it should show the Edit form' do
        expect(get :edit).to render_template('edit')
        # Redirect, and show error when not allowed:
      end
      it 'should display all the projects in the project dropdown' do
        get :edit
        expect(assigns(:projects)).to include(project_1)
        expect(assigns(:projects)).to include(project_2)
        expect(assigns(:projects)).to include(project_3)
      end
      it 'should return an OK http status' do
        expect(response).to have_http_status(:ok)
      end
    end

      describe 'for a cohort in project 2' do
        let(:project_id) { project_2.id }
        it 'should let them' do
          post :create, params
          cohort = assigns(:admin_cohort)
          expect(assigns(:admin_cohort)).to be_valid
          expect(response).to redirect_to(admin_cohort_path(cohort))
        end
      end
    end
  end

  describe 'Nested controller methods' do
    let(:user) { admin_user }
    let(:project) { project_2 }

    context 'when nested under project route' do
      context 'get index' do
        it 'should restrict the list of cohorts to that project' do
          get 'index', project_id: project.id
          expect(assigns('admin_cohorts')).to include(@cohort_2)
          expect(assigns('admin_cohorts')).not_to include(@cohort_1)
          expect(assigns('admin_cohorts')).not_to include(@cohort_3)
          expect(response).to have_http_status(:ok)
        end
      end
      context 'get new' do
        it 'should only display the selected project in the drop down' do
          get 'new', project_id: project.id
          expect(assigns('projects')).to include(project_2)
          expect(assigns('projects')).not_to include(project_1)
          expect(assigns('projects')).not_to include(project_3)
          expect(response).to have_http_status(:ok)
        end

        it 'should pre-select the correct project from the route' do
          [project_1, project_2, project_3].each do |chosen_project|
            get 'new', project_id: chosen_project.id
            new_admin_cohort = assigns('admin_cohort')
            expect(new_admin_cohort.project_id).to eq(chosen_project.id)
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end
end
