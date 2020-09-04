class LaraPage {

    getHeaderContent() {
        return cy.get('.intro-mod')
    }

    getBodyContent() {
        // test for which layout is in the class attribute for the layout
        return cy.get('.collapsible.content-mod')
    }

    getEmbeddables() {
        // nested within either header or body content
        return cy.get('.embeddables')
    }

    getCollapseQuestionsTab() {
        return this.getInfoAssessmentBlock().within(() => {
            cy.get('.question-tab')
        })
    }

    getInfoAssessmentBlock() {
        // stems from body content
        return cy.get('.ui-block-2').eq(1)
    }

    getInteractiveBlock() {
        // stems from body content
        return cy.get('.ui-block-1')
    }

    getQuestionInteractiveEmbeddable() {
        return this.getInfoAssessmentBlock().within(() => {
            cy.get('.embeddable-root')
        })
    }

    getPaginationItem(pageNumber) {
        return cy.get('.activity-mod').find('.pagination-item').eq(pageNumber)
    }

 } export default LaraPage;