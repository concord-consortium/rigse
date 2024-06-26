require 'spec_helper'

RSpec.describe API::V1::PermissionFormsController, type: :controller do
  let(:admin) { FactoryBot.generate(:admin_user) }

  before do
    sign_in admin
  end

  describe 'get an ok response from the index endpoint' do
    it 'GET index' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'returns a list of permission forms including permissions' do
      Portal::PermissionForm.create!(name: 'Test Form', url: 'http://example.com', project_id: 1)
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to match([
        hash_including('name' => 'Test Form', 'url' => 'http://example.com', 'project_id' => 1, 'is_archived' => false, 'can_delete' => true)
      ])
    end
  end

  it 'POST create creates a new permission form' do
    post :create, params: { permission_form: { name: 'Test Form', url: 'http://example.com', project_id: 1 } }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Test Form')
    expect(Portal::PermissionForm.first.name).to eq('Test Form')
  end

  it 'PUT update updates the permission form' do
    permission_form = Portal::PermissionForm.create!(name: 'Test Form', url: 'http://example.com', project_id: 1)
    put :update, params: { id: permission_form.id, permission_form: { name: 'New Name' } }
    expect(response).to have_http_status(:ok)
    expect(Portal::PermissionForm.find(permission_form.id).name).to eq('New Name')
  end

  it 'DELETE destroy deletes the permission form' do
    permission_form = Portal::PermissionForm.create!(name: 'Test Form', url: 'http://example.com', project_id: 1)
    expect(Portal::PermissionForm.count).to eq(1)
    delete :destroy, params: { id: permission_form.id }
    expect(response).to have_http_status(:ok)
    expect(Portal::PermissionForm.count).to eq(0)
  end

  describe 'GET search_teachers' do
    it 'returns an empty array if the name is blank' do
      get :search_teachers, params: { name: '' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["teachers"]).to eq([])
    end

    it 'returns a list of teachers with login matching the name' do
      teacher = FactoryBot.create(:teacher, user: FactoryBot.create(:user, login: 'test_teacher'))
      get :search_teachers, params: { name: 'test_teacher' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["teachers"]).to match([
        hash_including('id' => teacher.id, 'name' => teacher.user.name, 'email' => teacher.user.email, 'login' => teacher.user.login)
      ])
    end

    it 'returns a list of teachers with email matching the name' do
      teacher = FactoryBot.create(:teacher, user: FactoryBot.create(:user, email: 'test_teacher@mail.com'))
      get :search_teachers, params: { name: 'test_teacher' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["teachers"]).to match([
        hash_including('id' => teacher.id, 'name' => teacher.user.name, 'email' => teacher.user.email, 'login' => teacher.user.login)
      ])
    end

    it 'returns a list of teachers with first or last name matching the name' do
      teacher = FactoryBot.create(:teacher, user: FactoryBot.create(:user, first_name: 'John', last_name: 'Doe'))
      get :search_teachers, params: { name: 'John' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["teachers"]).to match([
        hash_including('id' => teacher.id, 'name' => teacher.user.name, 'email' => teacher.user.email, 'login' => teacher.user.login)
      ])

      get :search_teachers, params: { name: 'Doe' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["teachers"]).to match([
        hash_including('id' => teacher.id, 'name' => teacher.user.name, 'email' => teacher.user.email, 'login' => teacher.user.login)
      ])
    end

    it 'escapes provided name parameter' do
      teacher = FactoryBot.create(:teacher, user: FactoryBot.create(:user, login: 'test_teacher'))
      get :search_teachers, params: { name: 't__t_teacher' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["teachers"]).to eq([])

      get :search_teachers, params: { name: 't%t_teacher' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["teachers"]).to eq([])
    end

    it 'returns a list of teachers with provided limit' do
      FactoryBot.create_list(:teacher, 5, user: FactoryBot.create(:user, login: 'test_teacher'))
      get :search_teachers, params: { name: 'test_teacher', limit: 3 }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["teachers"].size).to eq(3)
      expect(JSON.parse(response.body)["limit_applied"]).to eq(true)
      expect(JSON.parse(response.body)["total_teachers_count"]).to eq(5)
    end
  end

  describe 'when user is a project admin' do
    let (:project) { FactoryBot.create(:project) }
    let (:another_project) { FactoryBot.create(:project) }
    let (:project_admin) { FactoryBot.generate(:author_user) }

    before do
      sign_in project_admin
      project_admin.add_role_for_project('admin', project)
    end

    it 'GET index returns permission forms from the project' do
      Portal::PermissionForm.create!(name: 'Test Form 1', url: 'http://example1.com', project_id: project.id)
      Portal::PermissionForm.create!(name: 'Test Form 2', url: 'http://example2.com', project_id: another_project.id)
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)).to match([
        hash_including('name' => 'Test Form 1', 'url' => 'http://example1.com', 'project_id' => project.id, 'is_archived' => false, 'can_delete' => true)
      ])
    end

    it 'DELETE is allowed if the permission form belongs to the project' do
      permission_form = Portal::PermissionForm.create!(name: 'Test Form', url: 'http://example.com', project_id: project.id)
      expect(Portal::PermissionForm.count).to eq(1)
      delete :destroy, params: { id: permission_form.id }
      expect(response).to have_http_status(:ok)
      expect(Portal::PermissionForm.count).to eq(0)
    end

    it 'DELETE is not allowed if the permission form does not belongs to the project' do
      permission_form = Portal::PermissionForm.create!(name: 'Test Form', url: 'http://example.com', project_id: another_project.id )
      expect(Portal::PermissionForm.count).to eq(1)
      delete :destroy, params: { id: permission_form.id }
      expect(response).to have_http_status(:forbidden)
      expect(Portal::PermissionForm.count).to eq(1)
    end

    it 'GET search_teachers returns a list of teachers from the project' do
      teacher1 = FactoryBot.create(:teacher, user: FactoryBot.create(:user, login: 'test_teacher1'))
      cohort = FactoryBot.create(:admin_cohort, project: project)
      teacher1.cohorts << cohort

      teacher2 = FactoryBot.create(:teacher, user: FactoryBot.create(:user, login: 'test_teacher2'))

      get :search_teachers, params: { name: 'test_teacher' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["teachers"].size).to eq(1)
      expect(body["teachers"]).to match([
        hash_including('id' => teacher1.id)
      ])
    end
  end

  describe 'when user is a project researcher without access to manage permission forms' do
    let (:project) { FactoryBot.create(:project) }
    let (:project_researcher) { FactoryBot.generate(:author_user) }

    before do
      sign_in project_researcher
      project_researcher.add_role_for_project('researcher', project, can_manage_permission_forms: false)
    end

    it 'GET index is not allowed' do
      Portal::PermissionForm.create!(name: 'Test Form', url: 'http://example.com', project_id: 1)
      get :index
      expect(response).to have_http_status(:forbidden)
    end

    it 'DELETE is not allowed' do
      permission_form = Portal::PermissionForm.create!(name: 'Test Form', url: 'http://example.com', project_id: project.id)
      expect(Portal::PermissionForm.count).to eq(1)
      delete :destroy, params: { id: permission_form.id }
      expect(response).to have_http_status(:forbidden)
      expect(Portal::PermissionForm.count).to eq(1)
    end

    it 'GET search_teachers is not allowed' do
      teacher1 = FactoryBot.create(:teacher, user: FactoryBot.create(:user, login: 'test_teacher1'))
      cohort = FactoryBot.create(:admin_cohort, project: project)
      teacher1.cohorts << cohort

      teacher2 = FactoryBot.create(:teacher, user: FactoryBot.create(:user, login: 'test_teacher2'))

      get :search_teachers, params: { name: 'test_teacher' }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'when user is a project researcher with access to manage permission forms' do
    let (:project) { FactoryBot.create(:project) }
    let (:another_project) { FactoryBot.create(:project) }
    let (:project_researcher) { FactoryBot.generate(:author_user) }

    before do
      sign_in project_researcher
      project_researcher.add_role_for_project('researcher', project, can_manage_permission_forms: true)
      project_researcher.add_role_for_project('researcher', another_project, can_manage_permission_forms: false)
    end

    it 'GET index returns permission forms from the project' do
      Portal::PermissionForm.create!(name: 'Test Form 1', url: 'http://example1.com', project_id: project.id)
      Portal::PermissionForm.create!(name: 'Test Form 2', url: 'http://example2.com', project_id: another_project.id)
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
      # Note that researchers are never allowed to delete a permission form
      expect(JSON.parse(response.body)).to match([
        hash_including('name' => 'Test Form 1', 'url' => 'http://example1.com', 'project_id' => project.id, 'is_archived' => false, 'can_delete' => false)
      ])
    end

    it 'DELETE is not allowed' do
      permission_form = Portal::PermissionForm.create!(name: 'Test Form', url: 'http://example.com', project_id: project.id)
      expect(Portal::PermissionForm.count).to eq(1)
      delete :destroy, params: { id: permission_form.id }
      expect(response).to have_http_status(:forbidden)
      expect(Portal::PermissionForm.count).to eq(1)
    end

    it 'GET search_teachers returns a list of teachers from the project' do
      teacher1 = FactoryBot.create(:teacher, user: FactoryBot.create(:user, login: 'test_teacher1'))
      cohort = FactoryBot.create(:admin_cohort, project: project)
      teacher1.cohorts << cohort

      teacher2 = FactoryBot.create(:teacher, user: FactoryBot.create(:user, login: 'test_teacher2'))

      get :search_teachers, params: { name: 'test_teacher' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["teachers"].size).to eq(1)
      expect(body["teachers"]).to match([
        hash_including('id' => teacher1.id)
      ])
    end
  end

end
