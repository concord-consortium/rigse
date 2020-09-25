
function getUsernameInput() {
        return cy.contains('Username').next().find('input')
    }

    function getPasswordInput() {
        return cy.contains('Password').next().find('input')
    }

    function getForgotPasswordModal() {
        getLoginModal().within(() => {
            cy.contains('Forgot your username or password?').click()
        })
        return cy.get('div#forgot-password-modal')
    }


    function closeModal() {
        cy.get('.portal-pages-close').click()
    }

Cypress.Commands.add("login", (username, password) => {
    cy.get('a.log-in').should('be.visible').and('contain', 'Log In').click()
    cy.get('.login-default-modal-content').within(() => {
        cy.contains('Username').next().find('input').type(username)
        cy.contains('Password').next().find('input').type(password)
        cy.wait(3000)
        cy.get('button.submit-btn').click()
    })    
})
Cypress.Commands.add("logout", () => {
    cy.get('a.log-out').should('be.visible').and('contain', 'Log Out').click()
})
Cypress.Commands.add("addAClass", (baseUrl, testClass) => {
    cy.visit("/portal/classes/new")
    cy.get("input#portal_clazz_name").type(testClass.className)
    cy.get("input#portal_clazz_class_word").type(testClass.classWord)
    cy.get("select#portal_clazz_school").select(testClass.schoolName)
    cy.get("input#portal_clazz_grade_levels_12").check().should("be.checked")
    cy.get("form.new_portal_clazz").submit()
})
Cypress.Commands.add("assignActivityToClass", (testClass) => {
    cy.visit("/search")
    cy.get(".search-form__field").find("input").type(testClass.activityName)
    cy.get("input#go-button").click({force:true})
    cy.get("input#include_contributed").check().should("be.checked")
    cy.contains("Assign to a Class").click({force:true})
    cy.get(".content").find("input").check()
    cy.get('td > .button').click({force:true})
    cy.get('.buttons_container > .button').click({force:true})
})
Cypress.Commands.add("registerStudents", (testClass) => {
    cy.get("div#clazzes_nav").contains("Classes").click({ force: true }).then(() => {
        cy.contains(testClass.className).click({force:true})
        cy.get("li.open--1fle3cuw").eq(1).within(() => {
            cy.contains("Student Roster").click({force:true})
        })
    })
    cy.wait(1000)
    cy.contains("Register & Add New Student").click({ force: true })
        for (let i = 0; i < testClass.studentTotal; i++) {
            let index = i + 1;
            cy.get("form.new_portal_student").find('input#user_first_name').type(testClass.firstName)
            cy.get("form.new_portal_student").find('input#user_last_name').type(testClass.lastName + index.toString())
            cy.get("form.new_portal_student").find('input#user_password').type(testClass.password)
            cy.get("form.new_portal_student").find('input#user_password_confirmation').type(testClass.password)
            cy.get("form.new_portal_student").find('.create_button > .pie').click({force:true})
            cy.wait(1000)
            cy.waitForSpinnerStudentRegistration()
            cy.get(".ui-window").within(() => {
                cy.contains("Cancel").click({force:true})
            })
        }
        cy.get(".ui-window").within(() => {
            cy.get("input.pie").eq(1).click({force:true})
        })
})
Cypress.Commands.add("waitForSpinnerStudentRegistration", () => {
    cy.get('.waiting', { timeout: 60000 }).should('not.exist')
})
Cypress.Commands.add("getInteractiveIframe", (pos=0) => {
  return cy.get('.interactive-container').eq(pos).within(() => {
    cy.get("iframe").its('0.contentDocument.body').should('not.be.empty')
    .then(cy.wrap)
  })
});
