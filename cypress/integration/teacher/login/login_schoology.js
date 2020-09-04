context("Teacher login with Schoology SSO", () => {
    before(() => {
        cy.visit('learn.concord.org')
    })

    it("logs into portal via google SSO", () => {
        cy.get('a.log-in').should('be.visible').and('contain', 'Log In').click()
        cy.get('.login-default-modal-content').within(() => {
            cy.get('a.badge').filter('#schoology').click()
        })
        /**
         * Redirection to third-party site causes cypress to crash
         * Seems like there is a solution with a new library which
         * is explained here https://github.com/lirantal/cypress-social-logins
         */
    })
})