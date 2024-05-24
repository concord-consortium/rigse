import React from 'react'
import { render } from '../../helpers/react-render'
import SignupModal from './signup_modal'
import Signup from './signup'
import LoginModal from './login_modal'
import ForgotPasswordModal from './forgot_password_modal'
import Modal from '../../helpers/modal'

//
// Map modal to CSS classes
//
const modalClasses = {}
modalClasses[LoginModal] = 'login-default-modal'
modalClasses[SignupModal] = 'signup-default-modal'
modalClasses[ForgotPasswordModal] = 'forgot-password-modal'

//
// Render signup form with the specified properties to the specified DOM id.
//
// Params
//  properties          - The properties
//  selectorOrElement   - DOM element selector
//
export const renderSignupForm = (properties, selectorOrElement) => {
  if (properties == null) {
    properties = {}
  }
  render(<Signup {...properties} />, jQuery(selectorOrElement)[0])
}

const openModal = (type, properties = {}, closeFunc) => {
  const modalContainerId = modalClasses[type]
  const modalContainerSelector = '#' + modalContainerId
  let modalContainer = jQuery(modalContainerSelector)
  if (modalContainer.length === 0) {
    modalContainer = jQuery("<div id='" + modalContainerId + "'>").appendTo('body')
  }

  if (properties.closeable == null) {
    properties.closeable = true
  }

  console.log('INFO creating modal with props', properties)
  render(React.createElement(type, properties), modalContainer[0])

  return Modal.showModal(modalContainerSelector,
    undefined,
    undefined,
    closeFunc,
    properties.closeable)
}

export const openLoginModal = (properties) => {
  openModal(LoginModal, properties)
}

export const openForgotPasswordModal = (properties) => {
  openModal(ForgotPasswordModal, properties)
}

export const openSignupModal = (properties) => {
  console.log('INFO modal props', properties)
  let closeFunc = null
  if (properties.omniauth) {
    closeFunc = function () {
      console.log('INFO closeFunc closing registration modal.')
      var redirectPath = null
      if (properties.omniauth && properties.omniauth_origin) {
        redirectPath = properties.omniauth_origin
      }
      logout(Modal.hideModal, Modal.hideModal, redirectPath)
    }
  }
  openModal(SignupModal, properties, closeFunc)
}

//
// Log out the current user
//
const logout = (successFunc, failFunc, redirectAfter) => {
  console.log('INFO logout() logging out...')

  jQuery.get('/api/v1/users/sign_out').done(function (data) {
    console.log('INFO logout success', data)

    if (successFunc) {
      successFunc()
    }

    if (redirectAfter) {
      console.log('INFO redirecting to ' + redirectAfter)
      window.location.href = redirectAfter
    } else {
      window.location.reload(true)
    }
  }).fail(function (err) {
    console.log('ERROR logout error', err)

    if (err.responseText) {
      var response = jQuery.parseJSON(err.responseText)
      console.log('ERROR logout error responseText', response.message)
    }

    if (failFunc) {
      failFunc()
    }
  })
}
