{div, p, ul, li} = React.DOM

modulejs.define 'components/signup/signup_modal',
[
  'components/signup/signup',
  'components/signup/sideinfo'
],
(
  SignupClass,
  SideInfoClass
) ->
  Signup = React.createFactory SignupClass
  SideInfo = React.createFactory SideInfoClass

  React.createClass
    render: ->
      (div {className: 'signup-default-modal-content'},
        (Signup {})
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
