require 'spec_helper'

RegexForAuthFailShow = /can not view the requested resource/
RegexForAuthFailNew = /can not create the requested resource/
RegexForAuthFailModify = /can not update the requested resource/
RegexForAuthFailDestroy = /can not destroy the requested resource/
RegexDeleteSuccess = /(.*) was deleted/
describe Admin::ProjectLinksController do
  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    allow(controller).to receive(:current_user).and_return(user)
    @link_1 = FactoryBot.create(:project_link, link_id: 'link1', href: 'http://link1.com', name: 'link 1', project: project_1)
    @link_2 = FactoryBot.create(:project_link, link_id: 'link2', href: 'http://link2.com', name: 'link 2', project: project_2)
    @link_3 = FactoryBot.create(:project_link, link_id: 'link3', href: 'http://link3.com', name: 'link 3', project: project_3)
  end

  let(:project_1) { FactoryBot.create(:project, name: 'project_1') }
  let(:project_2) { FactoryBot.create(:project, name: 'project_2') }
  let(:project_3) { FactoryBot.create(:project, name: 'project_3') }

  let(:admin_user) { FactoryBot.generate(:admin_user) }
  let(:user) { FactoryBot.create(:user) }

  shared_examples 'fails_to_modify' do
    it 'it should NOT let them' do
      put :update, full_params
      expect(response).to have_http_status(:redirect)
      expect(request.flash[:alert]).to match(RegexForAuthFailModify)
    end
  end

  describe 'A user not affiliated with a project' do
    describe 'GET index' do
      it 'wont see any links' do
        get :index
        expect(assigns[:project_links]).to eq([])
      end
    end

    describe 'Show' do
      it 'wont let them see any links' do
        [@link_1, @link_2, @link_3].each do |link|
          get :show, id: link.id
          # Redirect, and show error when not allowed:
          expect(response).to have_http_status(:redirect)
          expect(request.flash[:alert]).to match(RegexForAuthFailShow)
        end
      end
    end
    describe 'New' do
      it 'it wont let them create a new link' do
        get :new
        # Redirect, and show error when not allowed:
        expect(response).to have_http_status(:redirect)
        expect(request.flash[:alert]).to match(RegexForAuthFailNew)
      end
    end

    describe 'create' do
      it 'it wont let them create a new link' do
        put :create
        # Redirect, and show error when not allowed:
        expect(response).to have_http_status(:redirect)
        expect(request.flash[:alert]).to match(RegexForAuthFailNew)
      end
    end

    describe 'update' do
      it 'it wont let them update an existing link' do
        put :update, id: @link_1.id
        # Redirect, and show error when not allowed:
        expect(response).to have_http_status(:redirect)
        expect(request.flash[:alert]).to match(RegexForAuthFailModify)
      end
    end

    describe 'Destroy' do
      it 'it wont let them delete an existing link' do
        delete :destroy, id: @link_1.id
        # Redirect, and show error when not allowed:
        expect(response).to have_http_status(:redirect)
        expect(request.flash[:alert]).to match(RegexForAuthFailDestroy)
      end
    end
  end

  describe 'A user who is an admin for project 2' do
    before(:each) do
      user.add_role_for_project('admin', project_2)
    end

    describe 'GET index' do
      it 'can only see link 2' do
        get :index
        expect(assigns[:project_links]).not_to include(@link_1)
        expect(assigns[:project_links]).to include(@link_2)
        expect(assigns[:project_links]).not_to include(@link_3)
      end
    end
  end

  describe 'A user who is an admin for project 1' do
    before(:each) do
      user.add_role_for_project('admin', project_1)
    end

    describe 'GET index' do
      it 'can only see link 1' do
        get :index
        expect(assigns[:project_links]).to include(@link_1)
        expect(assigns[:project_links]).not_to include(@link_2)
        expect(assigns[:project_links]).not_to include(@link_3)
      end
    end

    describe 'Show' do
      describe 'link 1 (user IS a project admin)' do
        it 'lets them see it' do
          get :show, id:@link_1.id
          expect(assigns[:project_link]).to eq(@link_1)
          expect(response).to have_http_status(:ok)
        end
      end
      describe 'link 2 (user is NOT a project admin)' do
        it 'wont let them see it' do
          get :show, id:@link_2.id
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
        get :new
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'Edit' do
      it 'it should show the Edit form' do
        expect(get :edit, id: @link_1.id).to render_template('edit')
        # Redirect, and show error when not allowed:
      end
      it 'should display only the projects for which the user is an admin' do
        get :edit, id: @link_1.id
        expect(assigns(:projects)).to include(project_1)
        expect(assigns(:projects)).not_to include(project_2)
        expect(assigns(:projects)).not_to include(project_3)
      end
      it 'should return an OK http status' do
        get :edit, id: @link_1.id
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'Create' do
      let(:params) do
        {
          admin_project_link: {
            project_id: project_id,
            name: 'name',
            href: 'http://foo.com/',
            link_id: 'foo'
          }
        }
      end

      let(:invalid_params) do
        {
          admin_project_link: {
            project_id: project_id,
            name: nil
          }
        }
      end


      describe 'when creating a link for project 1 which they ARE admin for' do
        let(:project_id) { project_1.id }
        it 'it SHOULD let them' do
          post :create, params
          link = assigns(:project_link)
          expect(assigns(:project_link)).to be_valid
          expect(response).to redirect_to(admin_project_link_path(link))
        end

        describe 'with invalid parameters (missing name, link, etc)' do

          it 'should invadidate the model' do
            post :create, invalid_params
            expect(assigns(:project_link)).not_to be_valid
          end

          it 'should redisplay the new form' do
            post :create, invalid_params
            expect(response).to render_template('new')
          end

          it 'should render the dropdown project list' do
            post :create, invalid_params
            projects = assigns[:projects]
            expect(projects).not_to be_nil
          end

          it 'display field validation errors' do
            post :create, invalid_params
            link = assigns[:project_link]
            expect(link.errors.messages[:name]).to include "can't be blank"
            expect(link.errors.messages[:href]).to include "can't be blank"
            expect(link.errors.messages[:link_id]).to include "can't be blank"
          end
        end

      end

      describe 'when creating a link for project 2 (NOT their project)' do
        let(:project_id) { project_2.id }
        it 'it should NOT let them' do
          post :create, params
          # Redirect, and show error when not allowed:
          expect(response).to have_http_status(:redirect)
          expect(request.flash[:alert]).to match(RegexForAuthFailNew)
        end
      end
    end

    describe 'Update' do
      let(:params) do
        {
          admin_project_link: {
            project_id: new_project_id,
            name: 'updated name',
            href: 'http://foo.com/',
            link_id: 'foo'
          }
        }
      end
      let(:invalid_params) do
        {
          admin_project_link: {
            project_id: new_project_id,
            name: nil,
            href: nil,
            link_id: nil
          }
        }
      end



      context 'a link of a project which the user IS an admin' do
        let(:full_params) { params.merge(id: @link_1.id) }

        context 'and not changing the project' do
          let(:new_project_id) { project_1.id }
          it 'it SHOULD let them' do
            put :update, full_params
            expect(assigns(:project_link)).to be_valid
            expect(response).to redirect_to(admin_project_link_path(@link_1))
          end

          context 'when missing required parameters' do
            let(:full_params) { invalid_params.merge(id: @link_1.id) }

            it 'should invadidate the model' do
              put :update, full_params
              expect(assigns(:project_link)).not_to be_valid
            end

            it 'should redisplay the edit form' do
              put :update, full_params
              expect(response).to render_template('edit')
            end

            it 'should render the dropdown project list' do
              put :update, full_params
              projects = assigns[:projects]
              expect(projects).not_to be_nil
            end

            it 'display field validation errors' do
              put :update, full_params
              link = assigns[:project_link]
              expect(link.errors.messages[:name]).to include "can't be blank"
              expect(link.errors.messages[:href]).to include "can't be blank"
              expect(link.errors.messages[:link_id]).to include "can't be blank"
            end
          end
        end
        
        context 'and changing the project to one the user is not an admin of' do
          let(:new_project_id) { project_2.id }
          include_examples 'fails_to_modify'
        end

        context 'and changing the project to an invalid project' do
          let(:new_project_id) { 999999 }
          it 'it should NOT let them' do
            put :update, full_params
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context 'a link of a project which the user is NOT an admin' do
        let(:full_params) { params.merge(id: @link_2.id) }

        context 'and not changing the project' do
          let(:new_project_id) { project_1.id }
          include_examples 'fails_to_modify'
        end

        context 'and changing the project to one the user is not an admin of' do
          let(:new_project_id) { project_2.id }
          include_examples 'fails_to_modify'
        end

        context 'and changing the project to an invalid project' do
          let(:new_project_id) { 999999 }
          include_examples 'fails_to_modify'
        end
      end
    end

    describe 'Destroy' do
      context 'with their project link' do
        let(:link) { @link_1 }
        it 'it will let them' do
          delete :destroy, id: link.id
          # Redirect, and show error when not allowed:
          expect(response).to have_http_status(:redirect)
          expect(request.flash[:notice]).to match(RegexDeleteSuccess)
        end
      end
    end
  end

  describe 'A site admin' do
    let(:user) { admin_user }

    describe 'GET index' do
      it 'can see all of the links in the index' do
        get :index
        expect(assigns[:project_links]).to include(@link_1)
        expect(assigns[:project_links]).to include(@link_2)
        expect(assigns[:project_links]).to include(@link_3)
      end
    end

    describe 'Show' do
      describe 'link 1' do
        it 'can see it' do
          get :show, id: @link_1.id
          expect(assigns[:project_link]).to eq(@link_1)
          expect(response).to have_http_status(:ok)
        end
      end
      describe 'link 2' do
        it 'can see it' do
          get :show, id: @link_2.id
          expect(assigns[:project_link]).to eq(@link_2)
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
      it 'should display all the projects in the project dropdown' do
        get :new
        expect(assigns(:projects)).to include(project_1)
        expect(assigns(:projects)).to include(project_2)
        expect(assigns(:projects)).to include(project_3)
      end
      it 'should return an OK http status' do
        get :new
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'Create' do
      let(:params) do
        {
          admin_project_link: {
            project_id: project_id,
            name: 'name',
            href: 'http://foo.com/',
            link_id: 'foo'
          }
        }
      end
      describe 'for a link in project 1' do
        let(:project_id) { project_1.id }
        it 'it SHOULD let them create a new link' do
          post :create, params
          link = assigns(:project_link)
          expect(assigns(:project_link)).to be_valid
          expect(response).to redirect_to(admin_project_link_path(link))
        end
      end

      describe 'for a link in project 2' do
        let(:project_id) { project_2.id }
        it 'should let them' do
          post :create, params
          link = assigns(:project_link)
          expect(assigns(:project_link)).to be_valid
          expect(response).to redirect_to(admin_project_link_path(link))
        end
      end
    end

    describe 'Edit' do
      before(:each) do
        allow(Admin::ProjectLink).to receive(:find).and_return(@link_1)
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

    describe 'Update' do
      let(:params) do
        {
          admin_project_link: {
            project_id: new_project_id,
            name: 'updated name',
            href: 'http://foo.com/',
            link_id: 'foo'
          }
        }
      end
      let(:full_params) { params.merge(id: @link_1.id) }

      context 'not changing the project' do
        let(:new_project_id) { project_1.id }
        it 'it SHOULD let them' do
          put :update, full_params
          expect(assigns(:project_link)).to be_valid
          expect(response).to redirect_to(admin_project_link_path(@link_1))
        end
      end

      context 'changing the project to a valid project' do
        let(:new_project_id) { project_2.id }
        it 'it SHOULD let them' do
          put :update, full_params
          expect(assigns(:project_link)).to be_valid
          expect(response).to redirect_to(admin_project_link_path(@link_1))
        end
      end

      context 'changing the project to an invalid project' do
        let(:new_project_id) { 99999 }
        it 'it should NOT let them' do
          put :update, full_params
          expect(response).to have_http_status(:not_found)
        end
      end
    end

  end

  describe 'Nested controller methods' do
    let(:user) { admin_user }
    let(:project) { project_2 }

    context 'when nested under project route' do
      context 'get index' do
        it 'should restrict the list of links to that project' do
          get 'index', project_id: project.id
          expect(assigns('project_links')).to include(@link_2)
          expect(assigns('project_links')).not_to include(@link_1)
          expect(assigns('project_links')).not_to include(@link_3)
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
            new_project_link = assigns('project_link')
            expect(new_project_link.project_id).to eq(chosen_project.id)
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end

    context 'when user is a project admin of the project' do
      let(:user) {
        _user = FactoryBot.create(:user)
        _user.add_role_for_project('admin', project_2)
        _user
      }

      describe 'New' do
        it 'should pre-select the correct project from the route' do
          get 'new', project_id: project.id
          expect(assigns('projects')).to include(project)
          expect(assigns('project_link').project_id).to eq(project.id)
          expect(response).to have_http_status(:ok)
        end
      end
      describe 'Create' do
        let(:params) do
          {
            admin_project_link: {
              project_id: new_project_id,
              name: 'name',
              href: 'http://foo.com/',
              link_id: 'foo'
            }
          }
        end

        describe 'when creating a link for a project which they ARE admin for' do
          let(:new_project_id) { project.id }
          it 'SHOULD let them' do
            post :create, params
            link = assigns(:project_link)
            expect(assigns(:project_link)).to be_valid
            expect(response).to redirect_to(admin_project_link_path(link))
          end
        end
        describe 'when creating a link for a project which they are NOT admin for' do
          let(:new_project_id) { project_1.id }
          it 'should NOT let them' do
            post :create, params
            # Redirect, and show error when not allowed:
            expect(response).to have_http_status(:redirect)
            expect(request.flash[:alert]).to match(RegexForAuthFailNew)
          end
        end
      end
      describe 'Edit' do
        it 'it should show the Edit form' do
          expect(get :edit, id: @link_2.id).to render_template('edit')
          # Redirect, and show error when not allowed:
        end
        it 'should return an OK http status' do
          get :edit, id: @link_2.id
          expect(response).to have_http_status(:ok)
        end
      end
      describe 'Update' do
        let(:params) do
          {
            admin_project_link: {
              project_id: new_project_id,
              name: 'updated name',
              href: 'http://foo.com/',
              link_id: 'foo'
            }
          }
        end
        let(:full_params) { params.merge(id: @link_2.id) }

        context 'not changing the project' do
          let(:new_project_id) { project_2.id }
          it 'it SHOULD let them' do
            put :update, full_params
            expect(assigns(:project_link)).to be_valid
            expect(response).to redirect_to(admin_project_link_path(@link_2))
          end
        end
      end
    end
  end
end
