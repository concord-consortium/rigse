require 'spec_helper'

RSpec.feature 'Teachers and anonymous users should be able to see an assign button for resources', :WebDriver => true do

  context "when logged in as a student." do
    let!(:student_user)            { FactoryBot.create(:confirmed_user,
                                                       :login => "student_user",
                                                       :password => "password",
                                                       :first_name => 'Jonathan',
                                                       :last_name => 'Ames') }
    let!(:student) { FactoryBot.create(:portal_student, :user => student_user) }

    before do
      login_with_ui_as('student_user', 'password')
    end

    scenario "Student user should not see assign button", :js => true do
      visit "/browse/eresources/1"
      expect(page).to_not have_content("Assign")
    end
  end

  context "when not logged in." do
    scenario 'Anonymous user should see assign button', :js => true do
      visit "/browse/eresources/1"
      expect(page).to have_content("Assign")
    end

    scenario 'Anonymous user should be able to click assign button and see assign dialog modal.', :js => true do
      visit "/browse/eresources/1"
      click_on "Assign"
      using_wait_time(1) do
        expect(page).to have_content("To assign this resource to classes and track student work on learn.concord.org, log in or register as a teacher.")
      end
    end

    scenario "Anonymous user can click register button in assign dialog modal.", :js => true do
      visit "/browse/eresources/1"
      click_on "Assign"
      using_wait_time(1) do
        within("#assign-col") do
          click_on("Register")
        end
        expect(page).to have_css("div#signup-default-modal")
      end
    end

    scenario "Anonymous user can click login button in assign dialog modal.", :js => true do
      visit "/browse/eresources/1"
      click_on "Assign"
      using_wait_time(1) do
        within("#assign-col") do
          click_on("Log In")
        end
        expect(page).to have_css("div#login-default-modal")
      end
    end

    scenario "Anonymous user can click copy button in assign dialog modal.", :js => true do
      visit "/browse/eresources/1"
      click_on "Assign"
      using_wait_time(1) do
        within("#share-col") do
          click_on("Copy")
          expect(page).to have_content("Copied to clipboard!")
        end
      end
    end

  end

  context "when logged in as a teacher who has not set up classes yet." do
    let!(:teacher_user)            { FactoryBot.create(:confirmed_user,
                                                       :login => "teacher_user",
                                                       :password => "password",
                                                       :first_name => 'George',
                                                       :last_name => 'Christopher') }
    let!(:teacher_without_classes) { FactoryBot.create(:portal_teacher,
                                                       :user => teacher_user) }
    before do
      login_with_ui_as('teacher_user', 'password')
    end

    scenario 'Teacher user should see assign button', :js => true do
      visit "/browse/eresources/1"
      expect(page).to have_content("Assign")
    end

    scenario 'Teacher user should be able to click assign button and see assign dialog modal, but will not see a list of classes.', :js => true do
      # first, archive sample class
      visit "/portal/classes/manage"
      first("input[type='checkbox']").click
      visit "/browse/eresources/1"
      click_on "Assign"
      using_wait_time(1) do
        expect(page).to_not have_content("Register")
        expect(page).to_not have_content("Log In")
        expect(page).to_not have_content("Select the class(es) you want to assign this resource to below.")
        expect(page).to have_content("You don't have any active classes.")
      end
    end

    scenario "Teacher user can click copy button in assign dialog modal.", :js => true do
      visit "/browse/eresources/1"
      click_on "Assign"
      using_wait_time(1) do
        within("#share-col") do
          click_on("Copy")
          expect(page).to have_content("Copied to clipboard!")
        end
      end
    end
  end

  context "when logged in as a teacher who has set up classes already." do
    before do
      login_with_ui_as('teacher', 'password')
    end

    scenario 'Teacher user should see assign button', :js => true do
      visit "/browse/eresources/1"
      expect(page).to have_content("Assign")
    end

    scenario 'Teacher user should be able to click assign button, see assign dialog modal, and assign resource to a class.', :js => true do
      visit "/browse/eresources/1"
      click_on "Assign"
      using_wait_time(1) do
        expect(page).to_not have_content("Register")
        expect(page).to_not have_content("Log In")
        expect(page).to have_content("Select the class(es) you want to assign this resource to below.")
        within("#assign-col") do
          first(".unassigned_activity_class").click
          click_on "Save"
        end
        expect(page).to have_content("is assigned to the selected class(es) successfully.")
      end
    end

    scenario "Teacher user can click copy button in assign dialog modal.", :js => true do
      visit "/browse/eresources/1"
      click_on "Assign"
      using_wait_time(1) do
        within("#share-col") do
          click_on("Copy")
          expect(page).to have_content("Copied to clipboard!")
        end
      end
    end

  end
end
