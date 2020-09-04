context("Teacher login with Portal", () => {
    before(() => {
        cy.visit('/')
    })

    let credentials = {
        teacher : 'Test Teacher',
        username : 'test-teacher01',
        password : 'password'
    }

    function getUsernameInput() {
        return cy.contains('Username').next().find('input')
    }

    function getPasswordInput() {
        return cy.contains('Password').next().find('input')
    }

    function getLoginModal() {
        cy.get('a.log-in').should('be.visible').and('contain', 'Log In').click()
        return cy.get('.login-default-modal-content')
    }

    function getForgotPasswordModal() {
        getLoginModal().within(() => {
            cy.contains('Forgot your username or password?').click()
        })
        return cy.get('div#forgot-password-modal')
    }

    function getInputError() {
        return cy.get('form.forgot-password-form')
    }

    function closeModal() {
        cy.get('.portal-pages-close').click()
    }

    it("forgot password using google SSO email", () => {
        let googleEmail = "ksantos@concord.org"
        getForgotPasswordModal().within(() => {
            cy.get('input').type(googleEmail)
            cy.get('button.submit-btn').click()
            getInputError().should('contain', 'Error: This is a Google authenticated account. Please use Google to make password changes.')
            closeModal()
        })
    })

    it("forgot password using schoology SSO email", () => {
        let schoologyEmail = "ksantos+testadmin@concord.org"
        getForgotPasswordModal().within(() => {
            cy.get('input').type(schoologyEmail)
            cy.get('button.submit-btn').click()
            getInputError().should('contain', "We've sent you an email containing your username and a link for changing your password if you've forgotten it.")
            closeModal()
        })
    })

    it("logs into portal", () => {
        getLoginModal().within(() => {
            getUsernameInput().clear().should('be.empty')
            getPasswordInput().clear().should('be.empty')
            getUsernameInput().type(credentials.username)
            getPasswordInput().type(credentials.password)
            cy.get('button.submit-btn').click()
            cy.wait(1000)
        })
        cy.get('#clazzes_nav').should('contain', credentials.teacher)
    })
})