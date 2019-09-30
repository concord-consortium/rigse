context("Testing Login for Portal", () => {

    const portalProductionUrl = "https://learn.concord.org";
    const portalStagingUrl = "https://learn.staging.concord.org"


    const teacherUsername = "";
    const teacherPassword = ""

    const class1 = {
        className: "",
        activityName: "",
        studentTotal : "",
        firstName : "",
        lastName : "",
        password : ""
    }

    function login() {
        cy.visit(portalProductionUrl + "/users/sign_in")
        cy.get("input#user_login").type(teacherUsername)
        cy.get("input#user_password").type(teacherPassword)
        cy.get("form").submit()
        cy.wait(2000)
    }

    function openStudentRosterForClass() {
        cy.get("div#clazzes_nav").contains("Classes").click({ force: true }).then(() => {
            cy.contains(class1.className)
            cy.contains("Student Roster").click({ force: true })
        })
    }

    function registerStudents() {
        cy.contains("Register & Add New Student").click({ force: true })
        for (let i = 20; i < class1.studentTotal; i++) {
            let index = i + 1;
            cy.get("form.new_portal_student").find('input#user_first_name').type(class1.firstName)
            cy.get("form.new_portal_student").find('input#user_last_name').type(class1.lastName + index.toString())
            cy.get("form.new_portal_student").find('input#user_password').type(class1.password)
            cy.get("form.new_portal_student").find('input#user_password_confirmation').type(class1.password)
            cy.get("form.new_portal_student").find('.create_button > .pie').click({force:true})
            cy.wait(5000)
            cy.get(".ui-window").within(() => {
                cy.get("input.pie").eq(0).click({force:true})
                cy.wait(5000)
            })
        }
        cy.get(".ui-window").within(() => {
            cy.get("input.pie").eq(1).click({force:true})
        })
    }

    it("logs into portal and adds students to class", () => {

        login()
        openStudentRosterForClass()
        registerStudents()

    })
})

/**
 * Get all of the roughly 24 students in the class
 * Individually login as each c1-c24 students
 *      grab the token from the URL and save into json
 *      grab the domain uID from URL and save into json
 *      choose any group for this student and 
 */