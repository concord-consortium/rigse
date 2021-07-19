import React from 'react'
import Component from '../helpers/component'
import shuffleArray from '../helpers/shuffle-array'
import stemFinderResult from './stem-finder-result'
import portalObjectHelpers from '../helpers/portal-object-helpers'

const MaterialsCollection = Component({
  getInitialState: function () {
    return {
      materials: []
    }
  },

  getDefaultProps: function () {
    return {
      showTeacherResourcesButton: true
    }
  },

  UNSAFE_componentWillMount: function () {
    jQuery.ajax({
      url: Portal.API_V1.MATERIALS_BIN_COLLECTIONS,
      data: { id: this.props.collection,
        skip_lightbox_reloads: true
      },
      dataType: 'json',
      success: function (data) {
        let materials = data[0].materials
        if (this.props.randomize) {
          materials = shuffleArray(materials)
        }
        if (this.props.featured) {
          // props.featured is the ID of the material we
          // wish to insert at the start of the list
          let featuredID = this.props.featured
          let sortFeatured = function (a, b) {
            if (a.id === featuredID) return -1
            if (b.id === featuredID) return 1
            return 0
          }
          materials.sort(sortFeatured)
        }
        this.setState({ materials: materials })
        if (this.props.onDataLoad) {
          this.props.onDataLoad(materials)
        }
      }.bind(this)
    })
  },

  render: function () {
    const showTeacherResourcesButton = this.props.showTeacherResourcesButton

    if (this.state.materials.length === 0) {
      return null
    }

    return (
      <div className={'portal-pages-finder-materials-collection'}>
        {this.state.materials.map(function (material, i) {
          portalObjectHelpers.processResource(material)
          return stemFinderResult({ key: i, resource: material, showTeacherResourcesButton: showTeacherResourcesButton })
        })}
      </div>
    )
  }
})

export default MaterialsCollection
