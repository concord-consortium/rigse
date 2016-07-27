{div, p, ul, li} = React.DOM

modulejs.define 'components/signup/signup_modal',
[
  'components/signup/signup'
],
(
  SignupClass
) ->
  Signup = React.createFactory SignupClass

  React.createClass
    render: ->
      (div {className: 'signup-default-modal-content'},
        (Signup {})
        (div {className: 'side-info'},
          (div {className: 'side-info-header'}, 'Why sign up?')
          (p {}, 'It\'s free and you get access to several key features:')
          (ul {}, 
            (li {}, 'Create classes for your students and assign them activities')
            (li {}, 'Save student work')
            (li {}, 'Track student progress through activities')
          )
        )
      )

Portal.openSignupModal = ->
  modalContainerId = 'signup-default-modal'
  modalContainerSelector = '#' + modalContainerId
  modalContainer = jQuery(modalContainerSelector)
  if modalContainer.length == 0
    modalContainer = jQuery("<div id='#{modalContainerId}'>").appendTo('body')
  # Always remove and re-render modal again. It makes sure that user always starts with a clean form.
  ReactDOM.unmountComponentAtNode(modalContainer[0])
  SignupModal = React.createFactory modulejs.require('components/signup/signup_modal')
  ReactDOM.render SignupModal({}), modalContainer[0]
  # Finally, show modal using simple Portal library (see modal.js).
  Portal.showModal(modalContainerSelector)
