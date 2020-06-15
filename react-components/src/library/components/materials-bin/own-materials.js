import React from 'react'

import MBFetchDataHOC from './fetch-data-hoc'
import MBMaterialsCollection from './materials-collection'
import createFactory from '../../helpers/create-factory'

class _MBOwnMaterials extends React.Component {
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
        {this.props.materials != null
          ? <MBMaterialsCollection
            name='My activities'
            materials={this.props.materials}
            archive={this.props.archiveSingle}
            assignToSpecificClass={this.props.assignToSpecificClass}
          />
          : <div>Loading...</div>}
      </div>
    )
  }
}

const MBOwnMaterials = createFactory(MBFetchDataHOC(_MBOwnMaterials, () => ({

  dataStateKey: 'materials',

  dataUrl: Portal.API_V1.MATERIALS_OWN,

  requestParams () {
    if (this.props.assignToSpecificClass) {
      return { assigned_to_class: this.props.assignToSpecificClass }
    } else {
      return {}
    }
  }
})))

export default MBOwnMaterials
