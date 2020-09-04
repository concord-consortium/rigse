class PortalAuth {
    
    getLoginButton(){
        return cy.get('a.log-in')
    }

    getRegisterButton() {
        return cy.get('a.register')
    }
} export default PortalAuth;