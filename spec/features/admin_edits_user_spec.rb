require 'spec_helper'

RSpec.feature 'Admin goes to users page', :WebDriver => true do
  let!(:teacher1_user) { FactoryBot.create(:user, login: 'pteacher', password: 'password', first_name: 'Pat', last_name: 'Teacher') }
  let!(:teacher2_user) { FactoryBot.create(:user, login: 'rteacher', password: 'password', first_name: 'Reilly', last_name: 'Teacher') }
  let!(:student_user) { FactoryBot.create(:user, login: 'cstudent', password: 'password', first_name: 'Casey', last_name: 'Student') }
  let!(:cohort_a) { FactoryBot.create(:admin_cohort) }
  let!(:cohort_b) { FactoryBot.create(:admin_cohort) }
  let!(:project_a) { FactoryBot.create(:project, name: 'Project A', cohorts: [cohort_a]) }
  let!(:project_b) { FactoryBot.create(:project, name: 'Project B', cohorts: [cohort_b]) }
  let!(:teacher1) { FactoryBot.create(:portal_teacher, user: teacher1_user) }
  let!(:teacher2) { FactoryBot.create(:portal_teacher, user: teacher2_user, cohorts: [cohort_b]) }
  let!(:teacher1_class) { FactoryBot.create(:portal_clazz, teachers: [teacher1]) }
  let!(:student) { FactoryBot.create(:full_portal_student, user: student_user, clazzes: [teacher1_class]) }
  let!(:project_admin1) { FactoryBot.create(:user, login: 'project_admin1', password: 'password', can_add_teachers_to_cohorts: true) }
  let!(:project_admin2) { FactoryBot.create(:user, login: 'project_admin2', password: 'password', can_add_teachers_to_cohorts: false) }

  context "logged in as a portal admin." do
    before do
      @teacher1_name = "#{teacher1_user.first_name} #{teacher1_user.last_name}"
      @teacher2_name = "#{teacher2_user.first_name} #{teacher2_user.last_name}"
      @student_name = "#{student_user.first_name} #{student_user.last_name}"
      @cohort_a_name = "#{project_a.name}: #{cohort_a.name}"
      login_as('admin')
      visit users_path
    end

    scenario 'Portal admin can see both teachers and student in user list.', js: true do
      search_for_user(@student_name)
      expect(page).to have_content(@student_name)
      search_for_user(@teacher1_name)
      expect(page).to have_content(@teacher1_name)
      search_for_user(@teacher2_name)
      expect(page).to have_content(@teacher2_name)
    end

    scenario 'Portal admin can add a teacher to a cohort.', js: true do
      search_for_user(@teacher1_name)
      visit_user_edit_page(@teacher1_name)
      expect(page.body).to match(%r{#{@cohort_a_name}}i)
      add_teacher_to_cohort(@cohort_a_name)
      confirm_teacher_in_cohort(@teacher1_name, @cohort_a_name)
    end

    # Switch feature doesn't currently work in the testing environment
    #scenario 'Portal admin can switch to a teacher.', js: true do
      #search_for_user(@teacher1_name)
      #click_link("Switch")
      #visit root_path
      #click_link("My Classes")
      #find('a.portal-pages-main-nav-item__link', text: 'My Classes').click()
      #expect(page.body).to match(%r{#{teacher1_name}}i)
      #expect(page.body).to match(%r{#{'switch back'}}i)
    #end

  end

  context "logged in as a project admin that can add teachers to their project's cohorts." do
    before do
      init_project_admin(project_admin1, project_b)
      @teacher1_name = "#{teacher1_user.first_name} #{teacher1_user.last_name}"
      @teacher2_name = "#{teacher2_user.first_name} #{teacher2_user.last_name}"
      @student_name = "#{student_user.first_name} #{student_user.last_name}"
      @cohort_a_name = "#{project_a.name}: #{cohort_a.name}"
      @cohort_b_name = "#{project_b.name}: #{cohort_b.name}"
      login_as('project_admin1')
      visit users_path
    end

    scenario 'Project admin can view users page.', js: true do
      expect(current_path).to eq '/users'
      expect(page.body).to match(%r{#{'Show/Hide User Descriptions'}}i)
    end

    scenario 'Project admin cannot see students in user list before adding a teacher with students to a cohort.', js: true do
      search_for_user(@student_name)
      expect(page).to_not have_content(@student_name)
    end

    scenario 'Project admin can add a teacher to a cohort and then see their students in user list.', js: true do
      search_for_user(@teacher1_name)
      expect(page).to have_content(@teacher1_name)
      visit_user_edit_page(@teacher1_name)
      expect(page.body).to match(%r{#{@cohort_b_name}}i)
      add_teacher_to_cohort(@cohort_b_name)
      visit users_path
      search_for_user(@student_name)
      expect(page).to have_content(@student_name)
    end

    scenario 'Project admin cannot see cohorts for projects they are not an admin of.', js: true do
      search_for_user(@teacher1_name)
      visit_user_edit_page(@teacher1_name)
      expect(page.body).to_not match(%r{#{@cohort_a_name}}i)
    end

    scenario 'Project admin cannot fully edit a teacher before adding them to a cohort.', js: true do
      search_for_user(@teacher1_name)
      visit_user_edit_page(@teacher1_name)
      expect(page).to_not have_xpath("//input[@id='user_first_name']")
      expect(page).to_not have_xpath("//input[@id='user_last_name']")
      expect(page).to_not have_xpath("//input[@id='user_login']")
      expect(page).to_not have_xpath("//input[@id='user_email']")
      expect(page.body).to match(%r{#{@cohort_b_name}}i)
    end

    scenario 'Project admin can add a teacher to a cohort and then fully edit user.', js: true do
      search_for_user(@teacher1_name)
      visit_user_edit_page(@teacher1_name)
      expect(page.body).to match(%r{#{@cohort_b_name}}i)
      add_teacher_to_cohort(@cohort_b_name)
      confirm_teacher_in_cohort(@teacher1_name, @cohort_b_name)
      expect(page).to have_xpath("//input[@id='user_first_name']")
      expect(page).to have_xpath("//input[@id='user_last_name']")
      expect(page).to have_xpath("//input[@id='user_login']")
      expect(page).to have_xpath("//input[@id='user_email']")
    end

    # Switch feature doesn't currently work in the testing environment
    #scenario 'Project admin can switch to a teacher that belongs to a cohort of their project.', js: true do
      #search_for_user(@teacher1_name)
      #visit_user_edit_page(@teacher1_name)
      #add_teacher_to_cohort(@cohort_b_name)
      #search_for_user(@teacher1_name)
      #click_link("Switch")
      #visit root_path
      #click_link("My Classes")
      #find('a.portal-pages-main-nav-item__link', text: 'My Classes').click()
      #expect(page.body).to match(%r{#{teacher1_name}}i)
      #expect(page.body).to match(%r{#{'switch back'}}i)
    #end

  end

  context "logged in as a project admin that cannot add teachers to their project's cohorts." do
    before do
      init_project_admin(project_admin2, project_b)
      @teacher1_name = "#{teacher1_user.first_name} #{teacher1_user.last_name}"
      @teacher2_name = "#{teacher2_user.first_name} #{teacher2_user.last_name}"
      @student_name = "#{student_user.first_name} #{student_user.last_name}"
      @cohort_name = "#{project_b.name}: #{cohort_b.name}"
      login_as('project_admin2')
      visit users_path
    end

    scenario 'Project admin can view users page.', js: true do
      expect(current_path).to eq '/users'
      expect(page.body).to match(%r{#{'Show/Hide User Descriptions'}}i)
    end

    scenario 'Project admin cannot see students of teachers who are not in a project cohort.', js: true do
      search_for_user(@teacher1_name)
      expect(page).to have_content(@teacher1_name)
      search_for_user(@student_name)
      expect(page).to_not have_content(@student_name)
    end

    scenario 'Project admin cannot fully edit a teacher if they are not in a project a cohort.', js: true do
      search_for_user(@teacher1_name)
      visit_user_edit_page(@teacher1_name)
      expect(page).to_not have_xpath("//input[@id='user_first_name']")
      expect(page).to_not have_xpath("//input[@id='user_last_name']")
      expect(page).to_not have_xpath("//input[@id='user_login']")
      expect(page).to_not have_xpath("//input[@id='user_email']")
      expect(page.body).to match(%r{#{@cohort_b_name}}i)
    end

    scenario 'Project admin is not allowed to add a teacher to a cohort.', js: true do
      search_for_user(@teacher1_name)
      visit_user_edit_page(@teacher1_name)
      expect(page). to have_field @cohort_name, disabled: true
    end

    scenario 'Project admin can fully edit a teacher if the teacher is in a project cohort.', js: true do
      search_for_user(@teacher2_name)
      visit_user_edit_page(@teacher2_name)
      expect(page).to have_xpath("//input[@id='user_first_name']")
      expect(page).to have_xpath("//input[@id='user_last_name']")
      expect(page).to have_xpath("//input[@id='user_login']")
      expect(page).to have_xpath("//input[@id='user_email']")
    end

  end

  def init_project_admin(user, project)
    user.confirm!
    user.confirmed_at { Time.now }
    user.add_role_for_project('admin', project)
  end

  def search_for_user(user_name)
    find(:xpath, "//input[@id='search']").set user_name
    click_button('Search')
  end

  def visit_user_edit_page(teacher)
    click_link(teacher)
    click_link("edit")
  end

  def add_teacher_to_cohort(cohort)
    check(cohort)
    click_button('Save')
    expect(current_path).to eq '/users'
    expect(page.body).to match(%r{#{'successfully updated'}}i)
  end

  def confirm_teacher_in_cohort(teacher, cohort)
    find(:xpath, "//input[@id='search']").set teacher
    click_button('Search')
    click_link(teacher)
    click_link("edit")
    expect(page).to have_checked_field(cohort)
  end
end
