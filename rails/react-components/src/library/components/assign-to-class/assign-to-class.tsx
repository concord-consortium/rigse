import React from "react";
import { render, unmount } from "../../helpers/react-render";
import Modal from "../../helpers/modal";
import AssignModal, { requestErrorMessage } from "./assign-modal";

import css from "./style.scss";

const openModal = (type: any, properties: any = {}) => {
  const modalContainerSelector = "#" + css.assignModal;
  let modalContainer = jQuery(modalContainerSelector);
  if (modalContainer.length === 0) {
    modalContainer = jQuery("<div id=" + css.assignModal + ">").appendTo("body");
  }

  if (properties.closeable == null) {
    properties.closeable = true;
  }

  const closeFunc = () => {
    Modal.hideModal();
    // This should not be necessary; however, all this code is an awkward mix of React and non-React code (such as jQuery
    // manipulation of the DOM). Many of the components are not designed properly and assume that they are never updated
    // in their lifecycle, so they don't handle property updates well. Therefore, we unmount them here to avoid any issues,
    // as that's what happened before (prior to maintenance and the upgrade to React 18).
    unmount(modalContainer[0]);
  };
  properties.closeFunc = closeFunc;

  render(React.createElement(type, properties), modalContainer[0]);

  return Modal.showModal(modalContainerSelector,
    undefined,
    undefined,
    closeFunc,
    properties.closeable);
};

export default function openAssignToClassModal (properties: any) {
  const materialTypes: any = {
    ExternalActivity: "external_activity",
    Interactive: "interactive"
  };
  const materialType = materialTypes[properties.material_type];
  const data = {
    id: properties.material_id,
    material_type: materialType,
    include_related: "0"
  };
  jQuery.post(Portal.API_V1.MATERIAL_SHOW, data)
    .done(response => {
      properties.resourceTitle = response.name;
      properties.previewUrl = response.preview_url;
      properties.resourceType = response.material_type.toLowerCase();
      properties.savesStudentData = response.saves_student_data;
      if (Portal.currentUser.isAnonymous) {
        openModal(AssignModal, properties);
        return;
      }
      // Load the class list first. If the server refuses, for example because this tab is now in
      // learner mode, show only the message and not the pop-up.
      const classesData = {
        material_id: properties.material_id,
        material_type: properties.material_type
      };
      jQuery.post(Portal.API_V1.MATERIAL_UNASSIGNED_CLASSES, classesData)
        .done(classes => {
          properties.classes = classes;
          openModal(AssignModal, properties);
        })
        .fail(err => window.alert(requestErrorMessage(err)));
    })
    .fail(function (err) {
      if (err?.responseText) {
        const response = jQuery.parseJSON(err.responseText);
        console.error(response.message);
      }
    });
}
