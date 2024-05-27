import React from "react";
import { render } from "../../helpers/react-render";
import Modal from "../../helpers/modal";
import AssignModal from "./assign-modal";

import css from "./style.scss";

const openModal = (type: any, properties = {}, closeFunc: any) => {
  const modalContainerSelector = "#" + css.assignModal;
  let modalContainer = jQuery(modalContainerSelector);
  if (modalContainer.length === 0) {
    modalContainer = jQuery("<div id=" + css.assignModal + ">").appendTo("body");
  }

  // @ts-expect-error TS(2339): Property 'closeable' does not exist on type '{}'.
  if (properties.closeable == null) {
    // @ts-expect-error TS(2339): Property 'closeable' does not exist on type '{}'.
    properties.closeable = true;
  }

  render(React.createElement(type, properties), modalContainer[0]);

  return Modal.showModal(modalContainerSelector,
    undefined,
    undefined,
    closeFunc,
    // @ts-expect-error TS(2339): Property 'closeable' does not exist on type '{}'.
    properties.closeable);
};

export default function openAssignToClassModal (properties: any) {
  const materialTypes = {
    ExternalActivity: "external_activity",
    Interactive: "interactive"
  };
  // @ts-expect-error TS(7053): Element implicitly has an 'any' type because expre... Remove this comment to see the full error message
  const materialType = materialTypes[properties.material_type];
  properties.closeFunc = Modal.hideModal;
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
      openModal(AssignModal, properties, Modal.hideModal);
    })
    .fail(function (err) {
      if (err?.responseText) {
        const response = jQuery.parseJSON(err.responseText);
        console.log(response.message);
      }
    });
}
