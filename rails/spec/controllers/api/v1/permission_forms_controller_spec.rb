require 'spec_helper'

RSpec.describe API::V1::PermissionFormsController, type: :controller do
  let (:project) { FactoryBot.create(:project) }
  let (:another_project) { FactoryBot.create(:project) }
  let(:admin) { FactoryBot.generate(:admin_user) }
  let (:project_admin) { FactoryBot.generate(:author_user) }
  let (:project_researcher) { FactoryBot.generate(:author_user) }

  let (:clazz) { FactoryBot.create(:portal_clazz) }
  let (:teacher) { FactoryBot.create(:teacher, user: FactoryBot.create(:user, first_name: 'John', last_name: 'Doe', login: 'test_teacher', email: 'test_teacher_email@mail.com')) }
  let (:cohort) { FactoryBot.create(:admin_cohort, project: project) }
  let (:student) { FactoryBot.create(:full_portal_student) }
  let (:permission_form) { FactoryBot.create(:permission_form, project: project, name: 'Test Form', url: 'http://example.com') }
  let (:another_permission_form) { FactoryBot.create(:permission_form, project: another_project, name: 'Another Form', url: 'http://another.com') }

  before do
    sign_in admin

    teacher.cohorts << cohort
    clazz.teachers << teacher
    clazz.students << student
    student.permission_forms << permission_form
    student.permission_forms << another_permission_form
  end

  describe 'GET index' do
    it 'returns an empty array if there are no permission forms' do
      permission_form.destroy
      another_permission_form.destroy
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end

    it 'returns a list of permission forms including permissions' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to match([
        hash_including({ 'name' => 'Test Form', 'url' => 'http://example.com', 'project_id' => project.id, 'is_archived' => false, 'can_delete' => true }),
        hash_including({ 'name' => 'Another Form', 'url' => 'http://another.com', 'project_id' => another_project.id, 'is_archived' => false, 'can_delete' => true })
      ])
    end
  end

  describe 'POST create' do
    it 'creates a new permission form' do
      post :create, params: { permission_form: { name: 'Test Form 3', url: 'http://example.com', project_id: project.id } }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Test Form 3')
      expect(Portal::PermissionForm.last.name).to eq('Test Form 3')
    end
  end


  describe 'PUT update' do
    it 'updates the permission form' do
      put :update, params: { id: permission_form.id, permission_form: { name: 'New Name' } }
      expect(response).to have_http_status(:ok)
      expect(Portal::PermissionForm.find(permission_form.id).name).to eq('New Name')
    end
  end

  describe 'DELETE destroy' do
    it 'deletes the permission form' do
      expect(Portal::PermissionForm.count).to eq(2)
      delete :destroy, params: { id: permission_form.id }
      expect(response).to have_http_status(:ok)
      expect(Portal::PermissionForm.count).to eq(1)
    end
  end

  describe 'GET search_teachers' do
    it 'returns an empty array if the name is blank' do
      get :search_teachers, params: { name: '' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["teachers"]).to eq([])
    end

    it 'returns a list of teachers with login matching the name' do
      get :search_teachers, params: { name: 'test_teacher' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["teachers"]).to match([
        hash_including('id' => teacher.id, 'name' => teacher.user.name, 'email' => teacher.user.email, 'login' => teacher.user.login)
      ])
    end

    it 'returns a list of teachers with email matching the name' do
      get :search_teachers, params: { name: 'test_teacher_email' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["teachers"]).to match([
        hash_including('id' => teacher.id, 'name' => teacher.user.name, 'email' => teacher.user.email, 'login' => teacher.user.login)
      ])
    end

    it 'returns a list of teachers with first or last name matching the name' do
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
      get :search_teachers, params: { name: 't__t_teacher' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["teachers"]).to eq([])

      get :search_teachers, params: { name: 't%t_teacher' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["teachers"]).to eq([])
    end

    it 'returns a list of teachers with provided limit' do
      FactoryBot.create_list(:teacher, 5, user: FactoryBot.create(:user, first_name: 'Mark'))
      get :search_teachers, params: { name: 'Mark', limit: 3 }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["teachers"].size).to eq(3)
      expect(JSON.parse(response.body)["limit_applied"]).to eq(true)
      expect(JSON.parse(response.body)["total_teachers_count"]).to eq(5)
    end
  end

  describe 'GET projects' do
    it 'returns a list of projects the user can manage permission forms for' do
      get :projects
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe 'GET class_permission_forms' do
    it 'returns a list of students with their permission forms' do
      get :class_permission_forms, params: { class_id: clazz.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to match([
        hash_including('id' => student.id, 'name' => student.user.name, 'login' => student.user.login, 'permission_forms' => [
          hash_including('id' => permission_form.id, 'name' => permission_form.name, 'url' => permission_form.url, 'project_id' => permission_form.project_id, 'is_archived' => false),
          hash_including('id' => another_permission_form.id, 'name' => another_permission_form.name, 'url' => another_permission_form.url, 'project_id' => another_permission_form.project_id, 'is_archived' => false)
        ])
      ])
    end
  end

  describe 'POST bulk_update' do
    it 'adds and removes permission forms for a list of students' do
      permission_form_to_add = FactoryBot.create(:permission_form)
      post :bulk_update, params: {
        class_id: clazz.id,
        student_ids: [student.id],
        add_permission_form_ids: [permission_form_to_add.id],
        remove_permission_form_ids: [permission_form.id]
      }

      expect(response).to have_http_status(:ok)
      expect(student.reload.permission_forms).to include(permission_form_to_add)
      expect(student.reload.permission_forms).not_to include(permission_form)
    end

    it 'returns an error if any student does not belong to the specified class' do
      student.clazzes = []
      student.save

      post :bulk_update, params: {
        class_id: clazz.id,
        student_ids: [student.id],
        add_permission_form_ids: [permission_form.id]
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq('Some students do not belong to the specified class')
    end

    it 'returns an error if any permission form is not found' do
      post :bulk_update, params: {
        class_id: clazz.id,
        student_ids: [student.id],
        add_permission_form_ids: [0] # Invalid ID
      }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'when user is a project admin' do
    before do
      sign_in project_admin
      project_admin.add_role_for_project('admin', project)
    end

    it 'GET index returns permission forms from the project' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)).to match([
        hash_including('name' => 'Test Form', 'url' => 'http://example.com', 'project_id' => project.id, 'is_archived' => false, 'can_delete' => true)
      ])
    end

    it 'DELETE is allowed if the permission form belongs to the project' do
      expect(Portal::PermissionForm.count).to eq(2)
      delete :destroy, params: { id: permission_form.id }
      expect(response).to have_http_status(:ok)
      expect(Portal::PermissionForm.count).to eq(1)
    end

    it 'DELETE is not allowed if the permission form does not belongs to the project' do
      expect(Portal::PermissionForm.count).to eq(2)
      delete :destroy, params: { id: another_permission_form.id }
      expect(response).to have_http_status(:forbidden)
      expect(Portal::PermissionForm.count).to eq(2)
    end

    it 'GET search_teachers returns a list of teachers from the project' do
      teacher2 = FactoryBot.create(:teacher, user: FactoryBot.create(:user, login: 'test_teacher2'))

      get :search_teachers, params: { name: 'test_teacher' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["teachers"].size).to eq(1)
      expect(body["teachers"]).to match([
        hash_including('id' => teacher.id)
      ])
    end

    it 'GET projects returns a list of projects the user can manage permission forms for' do
      get :projects
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)).to match([
        hash_including('id' => project.id)
      ])
    end

    it 'GET class_permission_forms is allowed, but it limits permission forms to the project' do
      get :class_permission_forms, params: { class_id: clazz.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).first['permission_forms'].size).to eq(1)
      expect(JSON.parse(response.body).first['permission_forms'].first['id']).to eq(permission_form.id)
    end

    it 'POST bulk_update is allowed' do
      new_permission_form = FactoryBot.create(:permission_form, project: project)

      post :bulk_update, params: {
        class_id: clazz.id,
        student_ids: [student.id],
        add_permission_form_ids: [new_permission_form.id],
        remove_permission_form_ids: []
      }
      expect(response).to have_http_status(:ok)
      expect(student.reload.permission_forms).to include(new_permission_form)
    end

    it 'POST bulk_update is not allowed if the permission forms do not belong to the project' do
      post :bulk_update, params: {
        class_id: clazz.id,
        student_ids: [student.id],
        add_permission_form_ids: [],
        remove_permission_form_ids: [another_permission_form.id]
      }
      expect(response).to have_http_status(:forbidden)
      expect(student.reload.permission_forms).to include(another_permission_form)
    end
  end

  describe 'when user is a project researcher without access to manage permission forms' do
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
      expect(Portal::PermissionForm.count).to eq(2)
      delete :destroy, params: { id: permission_form.id }
      expect(response).to have_http_status(:forbidden)
      expect(Portal::PermissionForm.count).to eq(2)
    end

    it 'GET search_teachers is not allowed' do
      get :search_teachers, params: { name: 'test_teacher' }

      expect(response).to have_http_status(:forbidden)
    end

    it 'GET projects is not allowed' do
      get :projects
      expect(response).to have_http_status(:forbidden)
    end

    it 'GET class_permission_forms is not allowed' do
      get :class_permission_forms, params: { class_id: clazz.id }
      expect(response).to have_http_status(:forbidden)
    end

    it 'POST bulk_update is not allowed' do
      new_permission_form = FactoryBot.create(:permission_form)
      post :bulk_update, params: {
        class_id: clazz.id,
        student_ids: [student.id],
        add_permission_form_ids: [new_permission_form.id],
        remove_permission_form_ids: []
      }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'when user is a project researcher with access to manage permission forms' do
    before do
      sign_in project_researcher
      project_researcher.add_role_for_project('researcher', project, can_manage_permission_forms: true)
      project_researcher.add_role_for_project('researcher', another_project, can_manage_permission_forms: false)
    end

    it 'GET index returns permission forms from the project' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
      # Note that researchers are never allowed to delete a permission form
      expect(JSON.parse(response.body)).to match([
        hash_including('name' => 'Test Form', 'url' => 'http://example.com', 'project_id' => project.id, 'is_archived' => false, 'can_delete' => false)
      ])
    end

    it 'DELETE is not allowed' do
      expect(Portal::PermissionForm.count).to eq(2)
      delete :destroy, params: { id: permission_form.id }
      expect(response).to have_http_status(:forbidden)
      expect(Portal::PermissionForm.count).to eq(2)
    end

    it 'GET search_teachers returns a list of teachers from the project' do
      get :search_teachers, params: { name: 'test_teacher' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["teachers"].size).to eq(1)
      expect(body["teachers"]).to match([
        hash_including('id' => teacher.id)
      ])
    end

    it 'GET projects returns a list of projects the user can manage permission forms for' do
      get :projects
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body)).to match([
        hash_including('id' => project.id)
      ])
    end

    it 'GET class_permission_forms is allowed, but it limits permission forms to the project' do
      get :class_permission_forms, params: { class_id: clazz.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).first['permission_forms'].size).to eq(1)
      expect(JSON.parse(response.body).first['permission_forms'].first['id']).to eq(permission_form.id)
    end

    it 'POST bulk_update is allowed' do
      new_permission_form = FactoryBot.create(:permission_form, project: project)
      post :bulk_update, params: {
        class_id: clazz.id,
        student_ids: [student.id],
        add_permission_form_ids: [new_permission_form.id],
        remove_permission_form_ids: []
      }
      expect(response).to have_http_status(:ok)
      expect(student.reload.permission_forms).to include(new_permission_form)
    end

    it 'POST bulk_update is not allowed if the permission forms do not belong to the project' do
      post :bulk_update, params: {
        class_id: clazz.id,
        student_ids: [student.id],
        add_permission_form_ids: [],
        remove_permission_form_ids: [another_permission_form.id]
      }
      expect(response).to have_http_status(:forbidden)
      expect(student.reload.permission_forms).to include(another_permission_form)
    end
  end
end
