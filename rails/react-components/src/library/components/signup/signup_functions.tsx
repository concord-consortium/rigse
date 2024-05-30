import React from "react";
import { render, unmount } from "../../helpers/react-render";
import SignupModal from "./signup_modal";
import Signup from "./signup";
import LoginModal from "./login_modal";
import ForgotPasswordModal from "./forgot_password_modal";
import Modal from "../../helpers/modal";

//
// Map modal to CSS classes
//
const modalClasses: any = {};
modalClasses[LoginModal.toString()] = "login-default-modal";
modalClasses[SignupModal.toString()] = "signup-default-modal";
modalClasses[ForgotPasswordModal.toString()] = "forgot-password-modal";

//
// Render signup form with the specified properties to the specified DOM id.
//
// Params
//  properties          - The properties
//  selectorOrElement   - DOM element selector
//
export const renderSignupForm = (properties: any, selectorOrElement: any) => {
  if (properties == null) {
    properties = {};
  }
  render(<Signup {...properties} />, jQuery(selectorOrElement)[0]);
};

const getModalContainerId = (type: any) => modalClasses[type.toString()];

const getModalContainerSelector = (type: any) => "#" + getModalContainerId(type);

const getModalContainer = (type: any) => {
  const modalContainerSelector = getModalContainerSelector(type);
  let modalContainer = jQuery(modalContainerSelector);
  if (modalContainer.length === 0) {
    modalContainer = jQuery("<div id='" + getModalContainerId(type) + "'>").appendTo("body");
  }
  return modalContainer[0];
}

const hideModalOfType = (type: any) => {
  const modalContainer = getModalContainer(type);
  Modal.hideModal();
  // This should not be necessary; however, all this code is an awkward mix of React and non-React code (such as jQuery
  // manipulation of the DOM). Many of the components are not designed properly and assume that they are never updated
  // in their lifecycle, so they don't handle property updates well. Therefore, we unmount them here to avoid any issues,
  // as that's what happened before (prior to maintenance and the upgrade to React 18).
  unmount(modalContainer);
}

const openModal = (type: any, properties: any = {}, closeFunc?: () => void) => {
  const modalContainer = getModalContainer(type);

  if (properties.closeable == null) {
    properties.closeable = true;
  }

  if (!closeFunc) {
    closeFunc = () => hideModalOfType(type);
  }

  render(React.createElement(type, properties), modalContainer);

  return Modal.showModal(getModalContainerSelector(type),
    undefined,
    undefined,
    closeFunc,
    properties.closeable);
};

export const openLoginModal = (properties: any) => {
  openModal(LoginModal, properties);
};

export const openForgotPasswordModal = (properties: any) => {
  openModal(ForgotPasswordModal, properties);
};

export const openSignupModal = (properties: any) => {
  let closeFunc = undefined;
  if (properties.omniauth) {
    closeFunc = function () {
      let redirectPath = null;
      if (properties.omniauth && properties.omniauth_origin) {
        redirectPath = properties.omniauth_origin;
      }
      const hideModal = () => hideModalOfType(SignupModal);
      logout(hideModal, hideModal, redirectPath);
    };
  }
  openModal(SignupModal, properties, closeFunc);
};

//
// Log out the current user
//
const logout = (successFunc: any, failFunc: any, redirectAfter: any) => {
  jQuery.get("/api/v1/users/sign_out").done(function (data) {
    if (successFunc) {
      successFunc();
    }
    if (redirectAfter) {
      window.location.href = redirectAfter;
    } else {
      window.location.reload();
    }
  }).fail(function (err) {
    if (err.responseText) {
      const response = jQuery.parseJSON(err.responseText);
      console.error("ERROR logout error responseText", response.message);
    }

    if (failFunc) {
      failFunc();
    }
  });
};
