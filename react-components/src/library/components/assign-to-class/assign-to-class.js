import React from 'react'
import ReactDOM from 'react-dom'
import Modal from '../../helpers/modal'
import AssignModal from './assign-modal'

import css from './style.scss'

const openModal = (type, properties = {}, closeFunc) => {
  const modalContainerSelector = '#' + css.assignModal
  let modalContainer = jQuery(modalContainerSelector)
  if (modalContainer.length === 0) {
    modalContainer = jQuery('<div id=' + css.assignModal + '>').appendTo('body')
  }

  if (properties.closeable == null) {
    properties.closeable = true
  }

  ReactDOM.unmountComponentAtNode(modalContainer[0])
  var comp = React.createElement(type, properties)
  ReactDOM.render(comp, modalContainer[0])

  return Modal.showModal(modalContainerSelector,
    undefined,
    undefined,
    closeFunc,
    properties.closeable)
}

export default function openAssignToClassModal (properties) {
  const materialTypes = {
    ExternalActivity: 'external_activity',
    Interactive: 'interactive'
  }
  const materialType = materialTypes[properties.material_type]
  properties.closeFunc = Modal.hideModal
  const data = {
    id: properties.material_id,
    material_type: materialType,
    include_related: '0'
  }
  jQuery.post(Portal.API_V1.MATERIAL_SHOW, data).done(response => {
    properties.resourceTitle = response.name
    properties.previewUrl = response.preview_url
    properties.resourceType = response.material_type.toLowerCase()
    openModal(AssignModal, properties, Modal.hideModal)
  })
    .fail(function (err) {
      if (err && err.responseText) {
        const response = jQuery.parseJSON(err.responseText)
        console.log(response.message)
      }
    })
}
