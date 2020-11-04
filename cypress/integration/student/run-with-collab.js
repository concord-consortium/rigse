import LaraPage from "../../support/elements/lara_page"

describe('Testing logged in student run with collaborator', () => {
    beforeEach(() => {
        cy.visit('/')
    })

    let laraPage = new LaraPage;

    function getProgressBar(resourceName) {
        return cy.contains(resourceName).parent().parent().find('.progress')
    }

    const STUDENT_01 = {
        fullName: "portal reporttesting8",
        username: "preporttesting8",
        password: "password",
        classname: "New Class",
        resource: "Testing new activity",
        completePercentage: 'width:9.09091%',
        collabFullName: "portal reporttesting9",
        collabUsername: "preporttesting9"
    }

    const answers = [
        {
            index : 0,
            text : 'Choice A'
        },
        {
            index : 1,
            text : 'Choice B'
        },
        {
            index : 2,
            text : 'Choice C'
        }]

    let answer = answers[2]

    it('Logs in student and runs with collab, adds MC answer', () => {
        cy.login(STUDENT_01.username, STUDENT_01.password)
        cy.contains(STUDENT_01.fullName).should('be.visible')
        cy.get('#clazzes_nav').contains(STUDENT_01.classname).click()
        cy.wait(2000)
        //getNoProgressBar(STUDENT_01.resource).should('contain', "You haven't started this yet.")//.and('be.visible')
        cy.contains(STUDENT_01.resource).parent().parent().find('a.in_group').click({force:true})
        cy.get('.dialogContent--fOAjWgvb').find('select').select(STUDENT_01.collabFullName)
        cy.get('.dialogContent--fOAjWgvb').find('button').contains('Add').click()
        cy.get('.dialogContent--fOAjWgvb').find('button').contains('Run with Other Students').click()
        // Adds and answer for student in LARA activity page 1 MC question #1
        cy.get('.pagination-link').contains('1').click({force:true})
        laraPage.getInfoAssessmentBlock().within(() => {
            cy.getInteractiveIframe(0).find('#app').within(() => {
                cy.wait(2000)
                cy.get('.runtime--choices--question-int').find('input').eq(answer.index).click({force:true})
            })
        })
        cy.visit('https://learn.staging.concord.org/')
        cy.get('#clazzes_nav').contains(STUDENT_01.classname).click()
        getProgressBar(STUDENT_01.resource).should('have.attr', 'style', STUDENT_01.completePercentage)
    })

    it('Logs in as collab student to verify progress bar and answer data', () => {
        cy.login(STUDENT_01.collabUsername, STUDENT_01.password)
        cy.contains(STUDENT_01.collabFullName).should('be.visible')
        cy.get('#clazzes_nav').contains(STUDENT_01.classname).click()
        cy.wait(2000)
        getProgressBar(STUDENT_01.resource).should('have.attr', 'style', STUDENT_01.completePercentage)
        cy.contains(STUDENT_01.resource).parent().parent().find('a.solo').click({force:true})
        cy.get('.pagination-link').contains('1').click({force:true})
        laraPage.getInfoAssessmentBlock().within(() => {
            cy.getInteractiveIframe(0).find('#app').within(() => {
                cy.wait(2000)
                cy.get('.runtime--choices--question-int').find('input').eq(answer.index).should('have.attr', 'checked')
            })
        })
    })

})