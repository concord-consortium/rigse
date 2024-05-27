import React from "react";
import { render } from "../../helpers/react-render";
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

const openModal = (type: any, properties: any = {}, closeFunc?: any) => {
  const modalContainerId = modalClasses[type.toString()];
  const modalContainerSelector = "#" + modalContainerId;
  let modalContainer = jQuery(modalContainerSelector);
  if (modalContainer.length === 0) {
    modalContainer = jQuery("<div id='" + modalContainerId + "'>").appendTo("body");
  }

  if (properties.closeable == null) {
    properties.closeable = true;
  }

  render(React.createElement(type, properties), modalContainer[0]);

  return Modal.showModal(modalContainerSelector,
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
  let closeFunc = null;
  if (properties.omniauth) {
    closeFunc = function () {
      let redirectPath = null;
      if (properties.omniauth && properties.omniauth_origin) {
        redirectPath = properties.omniauth_origin;
      }
      logout(Modal.hideModal, Modal.hideModal, redirectPath);
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
