import React from 'react'
import createFactory from '../../helpers/create-factory'

import MBFetchDataHOC from './fetch-data-hoc'
import MBMaterialsCollection from './materials-collection'

class _MBUserMaterialsContainer extends React.Component {
  getVisibilityClass () {
    if (!this.props.visible) {
      return 'mb-hidden'
    } else {
      return ''
    }
  }

  render () {
    return (
      <div className={this.getVisibilityClass()}>
        {this.props.materials
          ? <MBMaterialsCollection
            materials={this.props.materials}
            assignToSpecificClass={this.props.assignToSpecificClass}
            archive={this.archive}
          />
          : <div>Loading...</div>}
      </div>
    )
  }
}

const MBUserMaterialsContainer = createFactory(MBFetchDataHOC(_MBUserMaterialsContainer, () => ({
  dataStateKey: 'materials',

  dataUrl: Portal.API_V1.MATERIALS_BIN_UNOFFICIAL_MATERIALS,

  requestParams () {
    if (this.props.assignToSpecificClass) {
      return {
        user_id: this.props.userId,
        assigned_to_class: this.props.assignToSpecificClass
      }
    } else {
      return { user_id: this.props.userId }
    }
  }
})))

export default MBUserMaterialsContainer
