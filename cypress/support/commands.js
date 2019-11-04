// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This is will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })
Cypress.Commands.add("login", (baseUrl, testTeacher) => {
    cy.visit(baseUrl + "/users/sign_in")
    cy.get("input#user_login").type(testTeacher.username)
    cy.get("input#user_password").type(testTeacher.password)
    cy.get("form").submit()
})
Cypress.Commands.add("addAClass", (baseUrl, testClass) => {
    cy.visit(baseUrl + "/portal/classes/new")
    cy.get("input#portal_clazz_name").type(testClass.className)
    cy.get("input#portal_clazz_class_word").type(testClass.classWord)
    cy.get("select#portal_clazz_school").select(testClass.schoolName)
    cy.get("input#portal_clazz_grade_levels_12").check().should("be.checked")
    cy.get("form.new_portal_clazz").submit()
})
Cypress.Commands.add("assignActivityToClass", (baseUrl, testClass) => {
    cy.visit(baseUrl + "/search")
    cy.get(".search-form__field").find("input").type(testClass.activityName)
    cy.get("input#go-button").click({force:true})
    cy.get("input#include_contributed").check().should("be.checked")
    cy.contains("Assign to a Class").click({force:true})
    cy.get(".content").find("input").check()
    cy.get('td > .button').click({force:true})
    cy.get('.buttons_container > .button').click({force:true})
})
Cypress.Commands.add("registerStudents", (baseUrl, testClass) => {
    cy.visit(baseUrl + "/recent_activity")
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
