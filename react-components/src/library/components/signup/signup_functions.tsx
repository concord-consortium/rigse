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
const modalClasses = {};
// @ts-expect-error TS(2538): Type 'typeof LoginModal' cannot be used as an inde... Remove this comment to see the full error message
modalClasses[LoginModal] = "login-default-modal";
// @ts-expect-error TS(2538): Type 'typeof SignupModal' cannot be used as an ind... Remove this comment to see the full error message
modalClasses[SignupModal] = "signup-default-modal";
// @ts-expect-error TS(2538): Type 'typeof ForgotPasswordModal' cannot be used a... Remove this comment to see the full error message
modalClasses[ForgotPasswordModal] = "forgot-password-modal";

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

const openModal = (type: any, properties = {}, closeFunc: any) => {
  // @ts-expect-error TS(7053): Element implicitly has an 'any' type because expre... Remove this comment to see the full error message
  const modalContainerId = modalClasses[type];
  const modalContainerSelector = "#" + modalContainerId;
  let modalContainer = jQuery(modalContainerSelector);
  if (modalContainer.length === 0) {
    modalContainer = jQuery("<div id='" + modalContainerId + "'>").appendTo("body");
  }

  // @ts-expect-error TS(2339): Property 'closeable' does not exist on type '{}'.
  if (properties.closeable == null) {
    // @ts-expect-error TS(2339): Property 'closeable' does not exist on type '{}'.
    properties.closeable = true;
  }

  console.log("INFO creating modal with props", properties);
  render(React.createElement(type, properties), modalContainer[0]);

  return Modal.showModal(modalContainerSelector,
    undefined,
    undefined,
    closeFunc,
    // @ts-expect-error TS(2339): Property 'closeable' does not exist on type '{}'.
    properties.closeable);
};

export const openLoginModal = (properties: any) => {
  // @ts-expect-error TS(2554): Expected 3 arguments, but got 2.
  openModal(LoginModal, properties);
};

export const openForgotPasswordModal = (properties: any) => {
  // @ts-expect-error TS(2554): Expected 3 arguments, but got 2.
  openModal(ForgotPasswordModal, properties);
};

export const openSignupModal = (properties: any) => {
  console.log("INFO modal props", properties);
  let closeFunc = null;
  if (properties.omniauth) {
    closeFunc = function () {
      console.log("INFO closeFunc closing registration modal.");
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
  console.log("INFO logout() logging out...");

  jQuery.get("/api/v1/users/sign_out").done(function (data) {
    console.log("INFO logout success", data);

    if (successFunc) {
      successFunc();
    }

    if (redirectAfter) {
      console.log("INFO redirecting to " + redirectAfter);
      window.location.href = redirectAfter;
    } else {
      // @ts-expect-error TS(2554): Expected 0 arguments, but got 1.
      window.location.reload(true);
    }
  }).fail(function (err) {
    console.log("ERROR logout error", err);

    if (err.responseText) {
      const response = jQuery.parseJSON(err.responseText);
      console.log("ERROR logout error responseText", response.message);
    }

    if (failFunc) {
      failFunc();
    }
  });
};
