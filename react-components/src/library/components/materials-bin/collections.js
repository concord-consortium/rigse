import React from 'react'
import createFactory from '../../helpers/create-factory'

import MBFetchDataHOC from './fetch-data-hoc'
import MBMaterialsCollection from './materials-collection'

class _MBCollections extends React.Component {
  getVisibilityClass () {
    if (!this.props.visible) {
      return 'mb-hidden'
    } else {
      return ''
    }
  }

  render () {
    const className = `mb-cell ${this.getVisibilityClass()}`
    return (
      <div className={className}>
        {this.props.collectionsData != null
          ? this.props.collectionsData.map((collection, idx) =>
            <MBMaterialsCollection
              key={idx}
              name={collection.name}
              materials={collection.materials}
              archive={this.archive}
              // Merge extra properties that can be provided in collections array.
              teacherGuideUrl={this.props.collections[idx].teacherGuideUrl}
              assignToSpecificClass={this.props.assignToSpecificClass}
            />)
          : <div>Loading...</div>}
      </div>
    )
  }
}

const MBCollections = createFactory(MBFetchDataHOC(_MBCollections, () => ({

  dataStateKey: 'collectionsData',

  dataUrl: Portal.API_V1.MATERIALS_BIN_COLLECTIONS,

  requestParams () {
    if (this.props.assignToSpecificClass) {
      return {
        id: this.props.collections.map(c => c.id),
        assigned_to_class: this.props.assignToSpecificClass
      }
    } else {
      return { id: this.props.collections.map(c => c.id) }
    }
  }
})))

export default MBCollections
