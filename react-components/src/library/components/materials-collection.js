import React from 'react'
import Component from '../helpers/component'
import shuffleArray from '../helpers/shuffle-array'
import stemFinderResult from './stem-finder-result'
import portalObjectHelpers from '../helpers/portal-object-helpers'
import { loadMaterialsCollection } from '../helpers/materials-collection-cache'

const MaterialsCollection = Component({
  getInitialState: function () {
    return {
      materials: [],
      loadedData: false
    }
  },

  getDefaultProps: function () {
    return {
      showTeacherResourcesButton: true
    }
  },

  UNSAFE_componentWillMount: function () {
    loadMaterialsCollection(this.props.collection, function (data) {
      let materials = data.materials
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
      this.setState({ materials: materials, loadedData: true })
    }.bind(this))
  },

  componentDidMount: function () {
    const checkForDataLoaded = () => {
      if (!this.props.onDataLoad) {
        return
      }
      if (this.state.loadedData) {
        this.props.onDataLoad(this.state.materials)
      } else {
        setTimeout(checkForDataLoaded, 10)
      }
    }

    checkForDataLoaded()
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
